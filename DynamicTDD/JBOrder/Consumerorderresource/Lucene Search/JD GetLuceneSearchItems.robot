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
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${minSaleQuantity}  1
${maxSaleQuantity}   50
${ITEM1}     abc
${ITEM2}     abc1
${ITEM3}     abc2

*** Test Cases ***

JD-TC-Get Lucene Search For ConsumerOrder-1

    [Documentation]  Get Lucene Search For ConsumerOrder

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END

    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
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


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME50}
    Set Suite Variable    ${accountId} 


    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}


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
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id1}    ${resp.json()}

    ${displayName}=     FakerLibrary.name
    Set Suite Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}


    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Suite Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


    ${displayName1}=     FakerLibrary.name
    Set Suite Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}


    ${displayName2}=     FakerLibrary.name
    Set Suite Variable              ${displayName2} 
    ${resp}=    Create Item Inventory  ${displayName2}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId3}  ${resp.json()}


    ${price1}=    Random Int  min=70  max=90
    ${price1}=                    Convert To Number  ${price1}  1
    Set Suite Variable    ${price1}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}    minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
    ${price2}=    Random Int  min=50   max=60
    ${price2}=                    Convert To Number  ${price2}  1
    Set Suite Variable    ${price2}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName2} = 	Convert To Lower Case 	${displayName2}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName2}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price2}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds3}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                         ${displayName2}

JD-TC-Get Lucene Search For ConsumerOrder-2

    [Documentation]  Get Lucene Search For ConsumerOrder  with another item name

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName1} = 	Convert To Lower Case 	${displayName1}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price1}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds2}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId2}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                                      ${displayName1}    

JD-TC-Get Lucene Search For ConsumerOrder-3

    [Documentation]  Get Lucene Search For ConsumerOrder  with another item name

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName} = 	Convert To Lower Case 	${displayName}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                                              ${displayName}

JD-TC-Get Lucene Search For ConsumerOrder-4

    [Documentation]  Get Lucene Search For ConsumerOrder  with aitem starting letter

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${first}= 	Split String 	${displayName}
    ${displayName} = 	Convert To Lower Case 	${displayName}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${first}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                                              ${displayName}

JD-TC-Get Lucene Search For ConsumerOrder-5

    [Documentation]  Get Lucene Search For ConsumerOrder  using all data

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName} = 	Convert To Lower Case 	${displayName}
    ${displayName1} = 	Convert To Lower Case 	${displayName1}
    ${displayName2} = 	Convert To Lower Case 	${displayName2}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['itemCode']}' == '${itemEncId1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds1}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                                              ${displayName}


        ELSE IF     '${resp.json()[${i}]['itemCode']}' == '${itemEncId2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price1}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds2}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId2}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                                      ${displayName1}  


        ELSE IF     '${resp.json()[${i}]['itemCode']}' == '${itemEncId3}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price2}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds3}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId3}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                         ${displayName2}                                           ${toggle[0]}

        END
    END

JD-TC-Get Lucene Search For ConsumerOrder-UH1

    [Documentation]  Get Lucene Search For ConsumerOrder  with invalid number

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${price1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}                                                           []



JD-TC-Get Lucene Search For ConsumerOrder-UH2

    [Documentation]  Get Lucene Search For ConsumerOrder  with invalid character

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name='abc'
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}                []

JD-TC-Get Lucene Search For ConsumerOrder-6

    [Documentation]  Get Lucene Search without login

    ${displayName} = 	Convert To Lower Case 	${displayName}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                                              ${displayName}

JD-TC-Get Lucene Search For ConsumerOrder-7

    [Documentation]  Get Lucene Search using provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME50}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayName} = 	Convert To Lower Case 	${displayName}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds1}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                                              ${displayName}

# *** Comments ***

JD-TC-Get Lucene Search For ConsumerOrder-8

    [Documentation]  Get items after provider consumer login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME51}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END

    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    # sleep  02s

    # ${resp}=  Get Store Type By EncId   ${St_Id}    
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME51}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId1}=  get_acc_id  ${HLPUSERNAME51}
    Set Suite Variable    ${accountId1} 


    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${p1_id}   ${resp.json()[0]['id']}


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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}



    ${displayName4}=     FakerLibrary.name
    Set Suite Variable              ${displayName4} 
    ${resp}=    Create Item Inventory  ${displayName4}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId3}  ${resp.json()}



    ${price4}=    Random Int  min=50   max=60
    ${price4}=                    Convert To Number  ${price4}  1
    Set Suite Variable    ${price4}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price4}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName4} = 	Convert To Lower Case 	${displayName4}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId1}    name=${displayName4}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['inventoryItem']}                                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}                                                            ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['price']}                                                              ${price4}
    Should Be Equal As Strings    ${resp.json()[0]['sOrderCatalogEncId']}                                                        ${soc_id1}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                        ${SOC_itemEncIds3}
    Should Be Equal As Strings    ${resp.json()[0]['itemCode']}                                        ${itemEncId3}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                         ${displayName4}
JD-TC-Get Lucene Search For ConsumerOrder-9

    [Documentation]  Get Lucene Search using provider consumer login

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${displayName4} = 	Convert To Lower Case 	${displayName4}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId1}    name=${displayName4}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                         ${displayName4}

JD-TC-Get Lucene Search For ConsumerOrder-10

    [Documentation]  search item with name starting with almost similar name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END

    IF  ${resp.json()['enableSalesOrder']}==${bool[0]}
        ${resp1}=  Enable/Disable SalesOrder  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableSalesOrder']}  ${bool[1]}
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}



    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME52}
    Set Test Variable    ${accountId} 



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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+309187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${Stidd}    ${resp.json()['id']}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}

    # ${displayName}=     FakerLibrary.name
    # Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${ITEM1}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${itemEncId1}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Test Variable              ${itemSourceEnum}    ${resp.json()['itemSourceEnum']}
    Set Test Variable              ${itemPropertyType}    ${resp.json()['itemPropertyType']}


    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


    # ${displayName1}=     FakerLibrary.name
    # Set Test Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${ITEM2}    isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId2}  ${resp.json()}


    # ${displayName2}=     FakerLibrary.name
    # Set Test Variable              ${displayName2} 
    ${resp}=    Create Item Inventory  ${ITEM3}     isBatchApplicable=${boolean[0]}    isInventoryItem=${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId3}  ${resp.json()}


    ${price1}=    Random Int  min=70  max=90
    ${price1}=                    Convert To Number  ${price1}  1
    Set Test Variable    ${price1}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}    minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
    ${price2}=    Random Int  min=50   max=60
    ${price2}=                    Convert To Number  ${price2}  1
    Set Test Variable    ${price2}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}       minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${displayName2} = 	Convert To Lower Case 	${displayName2}
    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${ITEM1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}

 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['itemCode']}' == '${itemEncId1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds1}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                                              ${ITEM1}


        ELSE IF     '${resp.json()[${i}]['itemCode']}' == '${itemEncId2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price1}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds2}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId2}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                                      ${ITEM2}  


        ELSE IF     '${resp.json()[${i}]['itemCode']}' == '${itemEncId3}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['inventoryItem']}                                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['batchApplicable']}                                                            ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                              ${price2}
            Should Be Equal As Strings    ${resp.json()[${i}]['sOrderCatalogEncId']}                                                        ${soc_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                        ${SOC_itemEncIds3}
            Should Be Equal As Strings    ${resp.json()[${i}]['itemCode']}                                        ${itemEncId3}
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                         ${ITEM3}                                           ${toggle[0]}

        END
    END

JD-TC-Get Lucene Search For ConsumerOrder-11

    [Documentation]  In the sales order catalog where inventory manager is on , only courier delivery is disable and store pickup is enabled. Then, try to add an item to the cart using Courier Service.


    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableInventory']}  ${bool[1]}
    END

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME270}
    Set Test Variable    ${accountId} 

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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+105187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}



    ${displayName}=     FakerLibrary.name
    Set Test Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}      isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

    ${resp}=   Create Inventory Catalog Item  ${inv_cat_encid1}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Test Variable              ${price} 


    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id}   ${Name}  ${boolean[0]}  ${inv_cat_encid}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  courierService=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable              ${soc_id1}    ${resp.json()}

    ${resp}=  Create SalesOrder Catalog Item-invMgmt True     ${soc_id1}    ${boolean[1]}     ${Inv_Cata_Item_Encid1}     ${price}    ${boolean[1]}   minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lucene Search For ConsumerOrder    ${accountId}    name=${displayName}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200