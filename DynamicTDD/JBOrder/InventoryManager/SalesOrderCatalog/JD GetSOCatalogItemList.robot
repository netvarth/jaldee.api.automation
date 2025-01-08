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
Library           /ebs/TDD/CustomKeywords.py
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
${minSaleQuantity}  2
${maxSaleQuantity}   50

*** Test Cases ***

JD-TC-Get Sales Order Catalog Items List-1

    [Documentation]  Test whether the system can successfully create items with all items having invMgmt set to false (with out Tax) Then it get List by Encid param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
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
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME7}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId      ${St_Id}  
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

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_cat_id}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${Inv_cat_id}
    
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
    Set Suite Variable  ${price}


    # ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}


    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}   ${Name}  ${boolean[1]}  ${inv_cat_encid}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${SO_Cata_Encid}    ${resp.json()}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${SO_Cata_Encid}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[1]}   minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    # ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    # ${resp}=  Get SalesOrder Catalog Item By Encid     ${SO_itemEncIds}      
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}    encId-eq=${SO_itemEncIds}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_itemEncIds}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['encId']}    ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}

JD-TC-Get Sales Order Catalog Items List-2

    [Documentation]  update sales order catalog Item .(inventory manager is false) then get sales order list by status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}    status-eq=${toggle[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_itemEncIds}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['encId']}    ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}

JD-TC-Get Sales Order Catalog Items List-3

    [Documentation]   Get SalesOrder Catalog item List by invCatId

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
# invCatId-eq=${Inv_cat_id} 
    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['price']}    ${price}
    Should Be Equal As Strings    ${resp.json()[0]['taxInclude']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchPricing']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${SO_itemEncIds}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['encId']}    ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}


JD-TC-Get Sales Order Catalog Items List-UH1

    [Documentation]  Get SalesOrder Catalog item List  with invalid catalog id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}     encId-eq=${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Sales Order Catalog Items List-UH2

    [Documentation]  Get SalesOrder Catalog item List without login.

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}     encId-eq=${SO_itemEncIds}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Sales Order Catalog Items List-UH3

    [Documentation]  Get SalesOrder Catalog item List using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}     encId-eq=${SO_itemEncIds}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get Sales Order Catalog Items List-UH4

    [Documentation]  Get SalesOrder Catalog item List using another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog Item List  sorderCatalogEncId-eq=${SO_Cata_Encid}     encId-eq=${SO_itemEncIds}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get Sales Order Catalog Items List-UH5

    [Documentation]  Get SalesOrder Catalog item List using with out sorderCatalogEncId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog Item List
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${SO_CATA_ENCID_FILTER_REQUIRED}

