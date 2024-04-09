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
@{spItemSource}      RX       Ayur


*** Test Cases ***
JD-TC-Get list by item encId-1
    [Documentation]   create of a batch of catalog items then Get list by item encId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME29}
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
    Set Suite Variable  ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    # ${resp}=  Create SalesOrder Inventory Catalog   ${store_id}   ${Name}  ${boolean[1]}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_cat_id}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${Inv_cat_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}

    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=  Get Item Inventory  ${itemEncId1}    
    Log   ${resp.json()}
    Set Suite Variable  ${sp-item-id}  ${resp.json()['id']}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_item_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_item_Id} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1
    Set Suite Variable  ${price}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${spItem}=  Create Dictionary  encId=${itemEncId1}   
    ${resp}=    Update SalesOrder Catalog Item      ${SO_itemEncIds}     ${boolean[1]}         ${price}    spItem=${spItem}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${catalogItem}=     Create Dictionary       encId=${SO_itemEncIds}
    #  catalogItem=${catalogItem}    

    ${resp}=   Create Catalog Item Batch-invMgmt False   ${SO_itemEncIds}     ${Name}     ${price}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid}  ${resp.json()[0]}

    ${resp}=   Get list by item encId   ${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${Name} 



JD-TC-Get list by item encId-2

    [Documentation]   create salesorder catalog items where inventory management is true then create catalog item batch where invmgnt is false then Get list by item encId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid1}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${SO_Cata_Encid1}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncId1}  ${resp.json()[0]}

    ${resp}=  Create Catalog Item Batch-invMgmt False      ${SO_itemEncId1}     ${Name}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid1}  ${resp.json()[0]}

    ${resp}=   Get list by item encId   ${SO_itemEncId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_itemEncId1}    
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid1} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${Name} 

JD-TC-Get list by item encId-3

    [Documentation]    create new catalog item batch and then Get list by item encId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.first name
    Set Suite Variable  ${Name1}
    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1
    Set Suite Variable  ${price1}
    ${Name2}=    FakerLibrary.last name
    Set Suite Variable  ${Name2}
    ${price2}=    Random Int  min=2   max=40
    ${price2}=  Convert To Number  ${price2}    1
    Set Suite Variable  ${price2}
    ${catalog_details}=  Create Dictionary          name=${Name1}   price=${price1}   

    ${resp}=   Create Catalog Item Batch-invMgmt False   ${SO_itemEncIds}     ${Name2}     ${price2}     ${catalog_details}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid2}  ${resp.json()[0]}
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid3}  ${resp.json()[1]}

    ${resp}=   Get list by item encId   ${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[2]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()[2]['name']}    ${Name1} 
    Should Be Equal As Strings    ${resp.json()[2]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[2]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[2]['encId']}    ${SO_Cata_Item_Batch_Encid3} 
    Should Be Equal As Strings    ${resp.json()[2]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[2]['name']}     ${Name1} 
    ${netRate1}=  Convert To Number  ${resp.json()[1]['price']}    1
    Should Be Equal As Strings    ${netRate1}    ${price2}
    Should Be Equal As Strings    ${resp.json()[1]['name']}    ${Name2} 
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${SO_Cata_Item_Batch_Encid2} 
    Should Be Equal As Strings    ${resp.json()[1]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${Name2} 
    ${netRate2}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate2}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${Name} 





JD-TC-Get list by item encId-4

    [Documentation]    update batch and Get list by item encId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name3}=    FakerLibrary.last name
    Set Suite Variable  ${Name3}

    ${resp}=  Update Catalog Item Batch-invMgmt False    ${SO_Cata_Item_Batch_Encid3}      ${Name3}     ${price1}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get list by item encId   ${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[2]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()[2]['name']}    ${Name3} 
    Should Be Equal As Strings    ${resp.json()[2]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[2]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[2]['encId']}    ${SO_Cata_Item_Batch_Encid3} 
    Should Be Equal As Strings    ${resp.json()[2]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[2]['name']}     ${Name3} 
    ${netRate1}=  Convert To Number  ${resp.json()[1]['price']}    1
    Should Be Equal As Strings    ${netRate1}    ${price2}
    Should Be Equal As Strings    ${resp.json()[1]['name']}    ${Name2} 
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${SO_Cata_Item_Batch_Encid2} 
    Should Be Equal As Strings    ${resp.json()[1]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${Name2} 
    ${netRate2}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate2}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${Name} 


JD-TC-Get list by item encId-5

    [Documentation]    update batch status as disable and Get list by item encId.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Catalog Item Batch Status   ${SO_Cata_Item_Batch_Encid2}     ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get list by item encId   ${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${netRate}=  Convert To Number  ${resp.json()[2]['price']}    1
    Should Be Equal As Strings    ${netRate}    ${price1}
    Should Be Equal As Strings    ${resp.json()[2]['name']}    ${Name3} 
    Should Be Equal As Strings    ${resp.json()[2]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[2]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[2]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[2]['encId']}    ${SO_Cata_Item_Batch_Encid3} 
    Should Be Equal As Strings    ${resp.json()[2]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[2]['name']}     ${Name3} 
    ${netRate1}=  Convert To Number  ${resp.json()[1]['price']}    1
    Should Be Equal As Strings    ${netRate1}    ${price2}
    Should Be Equal As Strings    ${resp.json()[1]['name']}    ${Name2} 
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[1]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${SO_Cata_Item_Batch_Encid2} 
    Should Be Equal As Strings    ${resp.json()[1]['status']}     ${toggle[1]} 
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${Name2} 
    ${netRate2}=  Convert To Number  ${resp.json()[0]['price']}    1
    Should Be Equal As Strings    ${netRate2}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name} 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['catalogItem']['encId']}    ${SO_itemEncIds}    
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['id']}    ${sp-item-id} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1} 
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_Cata_Item_Batch_Encid} 
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]} 
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${Name} 



JD-TC-Get list by item encId-UH1

    [Documentation]   Get list by item encId  with invalid catalog item id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME29}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get list by item encId   ${itemEncId1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_CATALOG_ITEM_BATCH_ID}
    

JD-TC-Get list by item encId-UH2

    [Documentation]  Get list by item encId without login

    ${resp}=   Get list by item encId   ${SO_Cata_Item_Batch_Encid2}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get list by item encId-UH3

    [Documentation]  Get list by item encId using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get list by item encId   ${SO_Cata_Item_Batch_Encid2}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


