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

JD-TC-Update Catalog Item Batch Status-1

    [Documentation]  Create Catalog Item Batch then disable the batch status.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME32}
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

    ${resp}=    Create Item Inventory  ${displayName}    isBatchApplicable=${boolean[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_item_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_item_Id}    isBatchApplicable=${boolean[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}

    ${resp}=   Create Inventory Catalog Item  ${Inv_cat_id}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${Inv_Cata_Item_Encid}  ${resp.json()[0]}

    ${price}=    Random Int  min=2   max=40

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

    ${spItem}=  Create Dictionary  encId=${itemEncId1}   
    ${resp}=    Update SalesOrder Catalog Item      ${SO_itemEncIds}     ${boolean[1]}         ${price}    spItem=${spItem}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Catalog Item Batch-invMgmt False      ${SO_itemEncIds}     ${Name}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid}  ${resp.json()[0]}

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}




JD-TC-Update Catalog Item Batch Status-2

    [Documentation]   create salesorder catalog items where inventory management is true then create catalog item batch where invmgnt is false then disable the status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
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

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${SO_Cata_Encid1}    ${boolean[1]}     ${Inv_Cata_Item_Encid}     ${price}    ${boolean[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncId1}  ${resp.json()[0]}

    ${resp}=  Create Catalog Item Batch-invMgmt False      ${SO_itemEncId1}     ${Name}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Item_Batch_Encid1}  ${resp.json()[0]}

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid1}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]}

JD-TC-Update Catalog Item Batch Status-3

    [Documentation]   enable batch status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid1}     ${toggle[0]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Catalog Item Batch By Encid   ${SO_Cata_Item_Batch_Encid1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-Update Catalog Item Batch Status-UH1

    [Documentation]   enable batch status thats already enabled.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid1}     ${toggle[0]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_ALREADY_ENABLED}

JD-TC-Update Catalog Item Batch Status-UH2

    [Documentation]   disable batch status thats already disabled.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${CAP_ALREADY_DISABLED}

JD-TC-Update Catalog Item Batch Status-UH3

    [Documentation]   change batch status with invalid encid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=   Update Catalog Item Batch Status      ${SO_itemEncId1}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVENORY_CATALOG_ITEM_BATCH}

JD-TC-Update Catalog Item Batch Status-UH4

    [Documentation]  change batch status without login

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Update Catalog Item Batch Status-UH5

    [Documentation]  change batch status using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Catalog Item Batch Status      ${SO_Cata_Item_Batch_Encid}     ${toggle[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}