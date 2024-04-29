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

JD-TC-Get Catalog Batch Count Filter-1

    [Documentation]   Get count filter with salesorderItemEncid.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME30}
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

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[1]} 
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

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${catalogitemid}  ${resp.json()['catalogItem']['id']}


    ${resp}=   Get Catalog Item Batch List   sorderCatalogItemEncId-eq=${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-2

    [Documentation]   Get count filter with price.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch List   sorderCatalogItemEncId-eq=${SO_itemEncIds}   price-eq=${price}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}   price-eq=${price} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-3

    [Documentation]   Get count filter with catalog item batch id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch List   sorderCatalogItemEncId-eq=${SO_itemEncIds}  encId-eq=${SO_Cata_Item_Batch_Encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  encId-eq=${SO_Cata_Item_Batch_Encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-4

    [Documentation]   Get Catalog Item Batch  count List with enabled status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch List    sorderCatalogItemEncId-eq=${SO_itemEncIds}  status-eq=${toggle[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  status-eq=${toggle[0]}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-5

    [Documentation]   Get Catalog Item Batch  count filter with enabled status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch List    sorderCatalogItemEncId-eq=${SO_itemEncIds}  sorderCatalogItem-eq=${catalogitemid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  sorderCatalogItem-eq=${catalogitemid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-6

    [Documentation]   Create Catalog Item Batch with same sales order item encid and then Get Catalog Item Batch count filter 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${price1}=    Random Int  min=2   max=40
    ${price1}=  Convert To Number  ${price1}    1

    ${Name1}=    FakerLibrary.last name

    ${resp}=   Create Catalog Item Batch-invMgmt False   ${SO_itemEncIds}     ${Name1}     ${price1}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid1}  ${resp.json()[0]}

    ${resp}=   Get Catalog Item Batch List    sorderCatalogItemEncId-eq=${SO_itemEncIds} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count    sorderCatalogItemEncId-eq=${SO_itemEncIds}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}


JD-TC-Get Catalog Batch Count Filter-UH1

    [Documentation]   Get Catalog Item Batch  count filter with invalid catalog item id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get Catalog Item Batch List    sorderCatalogItemEncId-eq=${SO_itemEncIds}  sorderCatalogItem-eq=${SO_itemEncIds}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  sorderCatalogItem-eq=${SO_itemEncIds}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-UH2

    [Documentation]   Get Catalog Item Batch count filter without catalogItemEncid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch Count    sorderCatalogItem-eq=${SO_itemEncIds}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${SORDERCATALOGITEMENCID_FILTER_REQUIRED}

JD-TC-Get Catalog Batch Count Filter-UH3

    [Documentation]   Get Catalog Item Batch count filter with status as disabled

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch List    sorderCatalogItemEncId-eq=${SO_itemEncIds}  status-eq=${toggle[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  status-eq=${toggle[1]}       
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-UH4

    [Documentation]   Get Catalog Item Batch count filter where price is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch List   sorderCatalogItemEncId-eq=${SO_itemEncIds}   price-eq=${EMPTY}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}   price-eq=${EMPTY}        
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-UH5

    [Documentation]   Get Catalog Item Batch count filter where sorderCatalogItemEncId is empty

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME30}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch List   sorderCatalogItemEncId-eq=${EMPTY}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Catalog Item Batch Count    sorderCatalogItemEncId-eq=${EMPTY}        
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-Get Catalog Batch Count Filter-UH6

    [Documentation]   Get count filter without login

    ${resp}=   Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  encId-eq=${SO_Cata_Item_Batch_Encid}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Catalog Batch Count Filter-UH7

    [Documentation]  Get Catalog Item Batch count filter using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Catalog Item Batch Count   sorderCatalogItemEncId-eq=${SO_itemEncIds}  encId-eq=${SO_Cata_Item_Batch_Encid}     
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

