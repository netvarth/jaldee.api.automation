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

*** Test Cases ***

JD-TC-Get Catalog Items Using ItemEncid-1

    [Documentation]  Create cart

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
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
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME20}
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
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+208187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}   storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id1}    ${resp.json()}

    ${displayName}=     FakerLibrary.name
    Set Suite Variable              ${displayName} 

    ${resp}=    Create Item Inventory  ${displayName}     isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${price}=    Random Int  min=2   max=40
    ${price}=                    Convert To Number  ${price}  1
    Set Suite Variable              ${price} 
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}     ${itemEncId1}     ${price}        minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds1}  ${resp.json()[0]}


    ${displayName1}=     FakerLibrary.name
    Set Suite Variable  ${displayName1}
    ${resp}=    Create Item Inventory  ${displayName1}    isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}

    ${displayName2}=     FakerLibrary.name
    Set Suite Variable              ${displayName2} 
    ${resp}=    Create Item Inventory  ${displayName2}     isBatchApplicable=${boolean[1]}    isInventoryItem=${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId3}  ${resp.json()}


    ${price1}=    Random Int  min=70  max=90
    ${price1}=                    Convert To Number  ${price1}  1
    Set Suite Variable    ${price1}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}    ${itemEncId2}      ${price1}         minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds2}  ${resp.json()[0]}

 
    ${price2}=    Random Int  min=50   max=60
    ${price2}=                    Convert To Number  ${price2}  1
    Set Suite Variable    ${price2}  
    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${soc_id1}      ${itemEncId3}    ${price2}      minSaleQuantity=${minSaleQuantity}  maxSaleQuantity=${maxSaleQuantity}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SOC_itemEncIds3}  ${resp.json()[0]}


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

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
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

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    # ${resp}=    Get Provider Catalog Item Filter    sorderCatalogEncId-eq=${soc_id1}   accountId-eq=${accountId}   storeEncId-eq=${store_id}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Strings    ${len}    3
 

    # FOR  ${i}  IN RANGE   ${len}

    #     IF  '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds1}'  
    #         Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


    #     ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds2}'      
    #         Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId2}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId2}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds2}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}


    #     ELSE IF     '${resp.json()[${i}]['encId']}' == '${SOC_itemEncIds3}'      
    #         Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                              ${accountId}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['encId']}                                       ${soc_id1}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['name']}                                        ${Name}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['catalog']['invMgmt']}                                     ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['spCode']}                                       ${itemEncId3}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['encId']}                                        ${itemEncId3}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['name']}                                         ${displayName2}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['invMgmt']}                                      ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['spItem']['batchEnabled']}                                 ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['price']}                                                  ${price2}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['batchPricing']}                                           ${bool[1]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['encId']}                                                  ${SOC_itemEncIds3}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                                ${bool[0]}
    #         Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                                 ${toggle[0]}

    #     END
    # END


    ${resp}=    Get catalog item by item encId      ${accountId}   ${SOC_itemEncIds1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
