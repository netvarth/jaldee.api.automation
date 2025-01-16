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

JD-TC-Get item list by catalog encId-1
    [Documentation]  Test whether the system can successfully create items with all items having invMgmt set to false (with out Tax) Then it Get item list by catalog encId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
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
    # Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    # Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME15}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    # Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    # Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

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

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}     onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    # ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_cat_id}  ${resp.json()}
    
    ${resp}=  Get Inventory Catalog By EncId   ${Inv_cat_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[1]}   isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_item_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_item_Id}   isBatchApplicable=${boolean[1]}   isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    # ${price}=    Random Int  min=2   max=40
    # ${price}=   Convert To Number  ${price}  1
    # Set Suite Variable  ${price}
    # ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr True --------------------------


    ${Store_note}=  FakerLibrary.name
    ${inv_cat_encid_List}=  Create List  ${Inv_cat_id}
    ${price}=    Random Int  min=2   max=40
    ${price}=  Convert To Number  ${price}    1
    Set Suite Variable  ${price}
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}  ${Store_note}  ${boolean[1]}  ${inv_cat_encid_List}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}
# ---------------------------------------------------------------------------------------------------------
# ------------------------------Create SalesOrder Catalog Item-invMgmt True-------------------------------

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${SO_Cata_Encid}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}



    ${resp}=  Get Item List By Catalog EncId     ${SO_Cata_Encid}      
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
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['name']}    ${Store_note}
    Should Be Equal As Strings    ${resp.json()[0]['catalog']['invMgmt']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['encId']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['spItem']['name']}    ${displayName}
    
JD-TC-Get item list by catalog encId-2
    [Documentation]  Another provider to try Get item list by catalog encId.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item List By Catalog EncId     ${SO_Cata_Encid}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}

JD-TC-Get item list by catalog encId-3
    [Documentation]   try Get item list by invalid catalog encId .

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME15}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item List By Catalog EncId     ${invalidstring}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_Invalid_Catalog_id}

JD-TC-Get item list by catalog encId-UH1
    [Documentation]  Get item list by catalog encId without login.

    ${resp}=  Get Item List By Catalog EncId     ${SO_Cata_Encid}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get item list by catalog encId-UH2
    [Documentation]  Get item list by catalog encId using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item List By Catalog EncId     ${SO_Cata_Encid}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}