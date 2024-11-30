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


*** Test Cases ***

JD-TC-Get SalesOrder Catalog List-1

    [Documentation]  create sales order catalog.(inventory manager is false) then get  catalog list by encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
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
  
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME36}
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

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog List   encId-eq=${sa_catlog_id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}




JD-TC-Get SalesOrder Catalog List-2

    [Documentation]  update sales order catalog .(inventory manager is false) then get sales order list by status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.first name
    Set Suite Variable  ${Name1}
    ${resp}=  Update SalesOrder Catalog    ${sa_catlog_id}  name=${Name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List   status-eq=${toggle[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name1}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}



JD-TC-Get SalesOrder Catalog List-3

    [Documentation]  Disable sales order catalog.(inventory manager is false).Then Get SalesOrder Catalog List by location

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update SalesOrder Catalog Status   ${sa_catlog_id}     ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List   locationId-eq=${locId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name1}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}


JD-TC-Get SalesOrder Catalog List-4

    [Documentation]  create  sales order catalog where name as number.(inventory manager is false).then get sales order list by name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${Name2}=    FakerLibrary.last name
    Set Suite Variable  ${Name2}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name2}  ${St_Id1}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id1}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False    ${store_id1}  ${invalidNum}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id1}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog List  name-eq=${invalidNum} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id1}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${invalidNum}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}





JD-TC-Get SalesOrder Catalog List-5

    [Documentation]  create  sales order  catalog where name as invalid string.(inventory manager is false).then get catalog list by store

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}  ${invalidstring}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id2}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog List  store-eq=${store_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${invalidstring}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}


JD-TC-Get SalesOrder Catalog List-6

    [Documentation]  create  sales order catalog where name as invalid string.(inventory manager is true).then get catalog list by invmgr

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inv_cat_encid}  ${resp.json()}
    ${inv_cat_encid1}=  Create List  ${inv_cat_encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id1}  ${Name}  ${boolean[1]}  ${inv_cat_encid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id4}  ${resp.json()}

    ${resp}=  Get SalesOrder Catalog List    invMgmt-eq=${bool[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id4}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${Name}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalog']['invCatEncIdList'][0]}    ${inv_cat_encid}

JD-TC-Get SalesOrder Catalog List-7

    [Documentation]  create  sales order catalog where name as invalid string.(inventory manager is true).then get catalog list by invmgr

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List    invCatEncId-eq=${inv_cat_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id4}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id1}
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${invalidstring}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalog']['invCatEncIdList'][0]}    ${inv_cat_encid}


JD-TC-Get SalesOrder Catalog List-UH1

    [Documentation]  Get SalesOrder Catalog List  with invalid catalog id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List     encId-eq=${store_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   []
    

JD-TC-Get SalesOrder Catalog List-UH2

    [Documentation]  Get SalesOrder Catalog List without login.

    ${resp}=  Get SalesOrder Catalog List    invCatEncId-eq=${inv_cat_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get SalesOrder Catalog List-UH3

    [Documentation]  Get SalesOrder Catalog List using sa login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get SalesOrder Catalog List    invCatEncId-eq=${inv_cat_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}


JD-TC-Get SalesOrder Catalog List-UH4

    [Documentation]  Get SalesOrder Catalog List using another provider login

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List    invCatEncId-eq=${inv_cat_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()}   []

JD-TC-Get SalesOrder Catalog List-8

    [Documentation]  Get SalesOrder Catalog List using inventory manager is on and with invcatalog encid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME36}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get SalesOrder Catalog List    invCatEncId-eq=${inv_cat_encid}   invMgmt-eq=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId}  
    Should Be Equal As Strings    ${resp.json()[0]['encId']}   ${sa_catlog_id4}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}    ${Name2}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}    ${store_id1}
    # Should Be Equal As Strings    ${resp.json()[0]['name']}    ${invalidstring}    
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['extPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['intPartnerOrder']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowNegativeTrueAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowtrueFutureNegativeAvial']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalog']['invCatEncIdList'][0]}    ${inv_cat_encid}





