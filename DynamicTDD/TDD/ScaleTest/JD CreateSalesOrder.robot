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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${originFrom}       NONE
${jpgfile}      /ebs/TDD/uploadimage.jpg
${fileSize}     0.00458
${order}        0
${PASSWORD}               Jaldee01
${var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${var_file1}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/usedproviders.py
${var_file2}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providerconsumer.py

*** Test Cases ***

JD-TC-Inventory Manager Work Flow-1
    [Documentation]    create a sales order with inventory ON case.

# --------------------- ---------------------------------------------------------------

    ${providers_list}=   Get File    ${var_file}
    ${pro_list}=   Split to lines  ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider}=  Remove String    ${provider}    ${SPACE}
        ${provider}  ${ph}=   Split String    ${provider}  =
        Set Test Variable  ${ph}
    
    END
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${num}=  find_last  ${var_file}



# ----------------------------------------getting datas from file----------------------------------

    ${used_providers_list}=   Get File    ${var_file1}
    ${used_pro_list}=   Split to lines  ${used_providers_list}

    FOR  ${usedprovider}  IN  @{used_pro_list}
        ${usedprovider}=  Remove String    ${usedprovider}    ${SPACE}
        ${usedprovider}  ${ID}=   Split String    ${usedprovider}  =
        IF  '${usedprovider}' == 'InventoryCatalogID${num}'   
            Set Test Variable  ${InventoryCatalogID}   ${ID}
        END
        IF  '${usedprovider}' == 'ItemID${num}'   
            Set Test Variable  ${ItemID}   ${ID}
        END
        IF  '${usedprovider}' == 'vendorId${num}'   
            Set Test Variable  ${vendorId}   ${ID}
        END
        IF  '${usedprovider}' == 'store_id${num}'   
            Set Test Variable  ${store_id}   ${ID}
        END
        IF  '${usedprovider}' == 'SalesOrderCatalogID${num}'   
            Set Test Variable  ${SalesOrderCatalogID}  ${ID}
        END
        IF  '${usedprovider}' == 'SOCatalogItemID${num}'   
            Set Test Variable  ${SOCatalogItemID}   ${ID}
        END
        IF  '${usedprovider}' == 'Provider_ConsumerID${num}'   
            Set Test Variable  ${Provider_ConsumerID}   ${ID}
        END
    
    
    END




# ----------------------------------------- Take sales order ------------------------------------------------
    ${Cg_encid}=  Create Dictionary   encId=${SalesOrderCatalogID}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}

    ${store}=  Create Dictionary   encId=${store_id}  


    ${quantity}=    Random Int  min=2   max=5
    ${quantity}=  Convert To Number  ${quantity}    1

    ${items}=  Create Dictionary   catItemEncId=${SOCatalogItemID}    quantity=${quantity}   catItemBatchEncId=${SOCatalogItemID}

    ${primaryMobileNo1}    Generate random string    10    123456789
    Set Suite Variable  ${primaryMobileNo1}


    ${note}=  FakerLibrary.name

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${Provider_ConsumerID}   ${Provider_ConsumerID}   ${originFrom}    ${items}    store=${store}        notes=${note}      notesForCustomer=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}
