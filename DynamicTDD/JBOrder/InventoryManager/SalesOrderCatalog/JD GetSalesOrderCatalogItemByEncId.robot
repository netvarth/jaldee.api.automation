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
@{spItemSource}      RX       Ayur

*** Test Cases ***

JD-TC-Get Sales Order Catalog Items By EncId-1

    [Documentation]  Test whether the system can successfully create items with all items having invMgmt set to false (with out Tax).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
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
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Suite Variable  ${TypeName2}
    sleep  02s

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

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_item_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_item_Id}   isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    ${price}=    Random Int  min=2   max=40
    ${price}=   Convert To Number  ${price}  1
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${resp}=  Get SalesOrder Catalog Item By Encid     ${SO_itemEncIds}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_itemEncIds}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['catalog']['encId']}    ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName}

JD-TC-Get Sales Order Catalog Items By EncId-2

    [Documentation]   create SO Catalog items with all items having invMgmt set to false (with Tax).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName1}=     FakerLibrary.name
    Set Suite Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=   Convert To Number  ${price}  1

    ${taxes}=    Random Int  min=2   max=40
    ${tax}=          Create List    ${taxes}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId2}     ${price}    TaxInclude=${boolean[1]}    taxes=${tax}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_TAXID}

    # ..... Create Tax ......

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${taxPercentage}=           Convert To Number  ${taxPercentage}  1
    ${cgst}=     Evaluate   ${taxPercentage} / 2
    ${sgst}=     Evaluate   ${taxPercentage} / 2
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}


    ${resp}=    Create Item Tax  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  ${cgst}  ${sgst}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}




    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Set Suite Variable              ${itemtax_id1}           ${resp.json()['id']}

    ${tax1}=     Create List  ${itemtax_id1}
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId2}     ${price}    TaxInclude=${boolean[1]}    taxes=${tax1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds1}  ${resp.json()[0]}


    ${resp}=  Get SalesOrder Catalog Item By Encid     ${SO_itemEncIds1}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['catalog']['encId']}    ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId2}
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName1}
    Should Be Equal As Strings    ${resp.json()['taxes'][0]}    ${itemtax_id1}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[1]}

JD-TC-Get Sales Order Catalog Items By EncId-3

    [Documentation]   create SO Catalog items with all items having invMgmt set to True (with out Tax).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv_cat_encid1}=  Create List  ${Inv_cat_id}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name}  ${boolean[1]}  ${inv_cat_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${ORDER_CATALOG_EXIST_WITH_SAME_NAME}

    ${Name1}=    FakerLibrary.last name
    Set Suite Variable  ${Name1}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name1}  ${boolean[1]}  ${inv_cat_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid1}  ${resp.json()}


    ${displayName2}=     FakerLibrary.name
    Set Suite Variable  ${displayName2}
    ${resp}=    Create Item Inventory  ${displayName2}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId3}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=   Convert To Number  ${price}  1

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True      ${SO_Cata_Encid1}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds3}  ${resp.json()[0]}

    ${resp}=  Get SalesOrder Catalog Item By Encid     ${SO_itemEncIds3}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_itemEncIds3}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['catalog']['encId']}    ${SO_Cata_Encid1}
    Should Be Equal As Strings    ${resp.json()['catalog']['name']}    ${Name1}
    Should Be Equal As Strings    ${resp.json()['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()['invCatItem']['encId']}    ${Inv_Cata_Item_Encid}

JD-TC-Get Sales Order Catalog Items By EncId-4

    [Documentation]   create SO Catalog items with all items having invMgmt set to True (with Tax).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=     FakerLibrary.name

    ${resp}=  Create Inventory Catalog   ${Name1}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Inv_cat_id}  ${resp.json()}
    
    ${resp}=  Get Inventory Catalog By EncId   ${Inv_cat_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}

    ${Name2}=    FakerLibrary.last name
    Set Suite Variable  ${Name2}
    ${inv_cat_encid1}=  Create List  ${Inv_cat_id}
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Name2}  ${boolean[1]}  ${inv_cat_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid2}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=   Convert To Number  ${price}  1
    ${taxes}=    Random Int  min=2   max=40
    ${tax}=          Create List    ${taxes}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True      ${SO_Cata_Encid1}    ${boolean[1]}     ${Inv_Cata_Item_Encid1}     ${price}    ${boolean[1]}    TaxInclude=${boolean[1]}    taxes=${tax}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NOT_CONNECTED_TO_ORDER_CATALOG}

    ${tax1}=     Create List  ${itemtax_id1}
    ${resp}=  Create SalesOrder Catalog Item-invMgmt True      ${SO_Cata_Encid2}    ${boolean[1]}     ${Inv_Cata_Item_Encid1}     ${price}    ${boolean[1]}    TaxInclude=${boolean[1]}    taxes=${tax1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds4}  ${resp.json()[0]}

    ${resp}=  Get SalesOrder Catalog Item By Encid     ${SO_itemEncIds4}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${SO_itemEncIds4}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['catalog']['encId']}    ${SO_Cata_Encid2}
    Should Be Equal As Strings    ${resp.json()['catalog']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()['catalog']['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['spItem']['encId']}    ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()['spItem']['name']}    ${displayName2}
    Should Be Equal As Strings    ${resp.json()['invCatItem']['encId']}    ${Inv_Cata_Item_Encid1}
    Should Be Equal As Strings    ${resp.json()['taxes'][0]}    ${taxes}
    Should Be Equal As Strings    ${resp.json()['taxInclude']}    ${bool[1]}

