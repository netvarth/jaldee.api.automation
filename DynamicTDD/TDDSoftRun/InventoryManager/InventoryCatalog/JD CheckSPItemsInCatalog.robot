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

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_

*** Keywords ***
Check SP Items In Catalog
    [Arguments]    ${spItem}      @{vargs}

    ${len}=  Get Length  ${vargs}
    ${data}=  Create List  

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${data}  ${vargs[${index}]}
    END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/inventory/inventorycatalog/spitem/${spItem}  data=${data}  expected_status=any
   RETURN  ${resp}

*** Test Cases ***

JD-TC-Check SP Items In Catalog-1

    [Documentation]  Create two Inventory Catalog Item then check SP Items In Catalog .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME20}
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
    Set Suite Variable    ${Name} 
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
    Set Suite Variable  ${id}  ${resp.json()['id']}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}

    ${Name1}=     FakerLibrary.name
    Set Suite Variable    ${Name1} 
    ${resp}=  Create Inventory Catalog   ${Name1}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid1}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}

    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

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

    ${resp}=   Get Item Inventory  ${itemEncIds}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${itemSourceEnum}  ${resp.json()['itemSourceEnum']}


    # ${resp}=   Create Inventory Catalog Item  ${encid}   ${itemEncId1}  
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${inv_cat}  ${resp.json()[0]}


    ${resp}=   Create Inventory Catalog Item  ${encid1}    ${itemEncIds}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_cat1}  ${resp.json()[0]}

    ${resp}=   Check SP Items In Catalog     ${itemEncIds}   ${encid}   ${encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['icEncId']}    ${encid1}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['lotNumber']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['invCatalogName']}    ${Name1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${inv_cat1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}   ${itemEncIds}
    Should Be Equal As Strings    ${resp.json()[0]['item']['name']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[0]['item']['itemSourceEnum']}    ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${id}


JD-TC-Check SP Items In Catalog-UH1

    [Documentation]  Check SP Items In Catalog

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=   Check SP Items In Catalog     ${itemEncIds}      ${encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}  []



JD-TC-Check SP Items In Catalog-UH2

    [Documentation]  Check SP Items In Catalog without login.

    ${resp}=   Check SP Items In Catalog     ${itemEncId1}   ${encid}   ${encid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Check SP Items In Catalog-UH3

    [Documentation]  Check SP Items In Catalog with invalid catalog id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Check SP Items In Catalog     ${itemEncId1}   ${inv_cat1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${Invalid_inventory_catalog_Id}


JD-TC-Check SP Items In Catalog-UH4

    [Documentation]  Item is not added in catalog then check sp item in catalog

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Check SP Items In Catalog     ${itemEncId1}      ${encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

