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

comment   Dev Removed this url
*** Test Cases ***

*** Comments ***
JD-TC-Get inventory catalog item by inventory catalog encoded id-1

    [Documentation]  Get inventory catalog item by inventory catalog encoded id.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
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
    sleep  02s
    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME41}
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


    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${inventoryCatalogId}  ${resp.json()['id']}
    Set Suite Variable  ${StoreId}  ${resp.json()['storeId']}

    ${displayName}=     FakerLibrary.name
    Set Suite Variable  ${displayName}
    ${resp}=    Create Item Inventory  ${displayName}     isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=   Get Item Inventory  ${itemEncId1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${itemSourceEnum}  ${resp.json()['itemSourceEnum']}

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=    Create Item Inventory  ${categoryName}   categoryCode=${Ca_Id}    isInventoryItem=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncIds}  ${resp.json()}
    ${resp}=   Get Item Inventory  ${itemEncIds}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Set Suite Variable  ${itemSourceEnum1}  ${resp.json()['itemSourceEnum']}


    ${resp}=   Create Inventory Catalog Item  ${encid}   ${itemEncId1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${EncId1}  ${resp.json()[0]}

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[0]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['lotNumber']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${EncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}   ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['name']}    ${displayName}
    Should Be Equal As Strings   ${resp.json()[0]['item']['itemSourceEnum']}    ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}    ${itemEncId1}


JD-TC-Get inventory catalog item by inventory catalog encoded id-2

    [Documentation]  Create Inventory Catalog Item from main account then Get inventory catalog item by inventory catalog encoded id from user login.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Create Inventory Catalog Item  ${encid}    ${itemEncIds}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${EncId2}  ${resp.json()[0]}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+${ran int}
    Set Test Variable  ${PUSERNAME_U1}
    clear_users  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Test Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Test Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Test Variable  ${dob1}
    ${pin1}=  get_pincode
    Set Test Variable  ${pin1}

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}


    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${encid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[0]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['lotNumber']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${EncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}   ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['name']}    ${displayName}
    Should Be Equal As Strings   ${resp.json()[0]['item']['itemSourceEnum']}    ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[1]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[1]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[1]['lotNumber']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[1]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[1]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${EncId2}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}
    Should Be Equal As Strings    ${resp.json()[1]['item']['name']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[1]['item']['itemSourceEnum']}    ${itemSourceEnum1}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}



JD-TC-Get inventory catalog item by inventory catalog encoded id-3

    [Documentation]  update inventory catalog items then Get inventory catalog item by inventory catalog encoded id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Update Inventory Catalog Item      ${boolean[1]}      ${encid}     ${EncId2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[0]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['lotNumber']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${EncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}   ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['name']}    ${displayName}
    Should Be Equal As Strings    ${resp.json()[0]['item']['itemSourceEnum']}    ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[1]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[1]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[1]['lotNumber']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[1]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[1]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${EncId2}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}
    Should Be Equal As Strings    ${resp.json()[1]['item']['name']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[1]['item']['itemSourceEnum']}    ${itemSourceEnum1}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}

JD-TC-Get inventory catalog item by inventory catalog encoded id-4

    [Documentation]  update inventory catalog items status then Get inventory catalog item by inventory catalog encoded id

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Inventory Catalog Item status    ${EncId2}  ${InventoryCatalogStatus[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${encid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[0]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[0]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[0]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['lotNumber']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${EncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}   ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[0]['item']['name']}    ${displayName}
    Should Be Equal As Strings   ${resp.json()[0]['item']['itemSourceEnum']}    ${itemSourceEnum}
    Should Be Equal As Strings    ${resp.json()[0]['item']['spCode']}    ${itemEncId1}
    Should Be Equal As Strings    ${resp.json()[1]['accountId']}    ${accountId} 
    Should Be Equal As Strings    ${resp.json()[1]['inventoryCatalogId']}    ${inventoryCatalogId}     
    Should Be Equal As Strings    ${resp.json()[1]['icEncId']}   ${encid}
    Should Be Equal As Strings    ${resp.json()[1]['batchApplicable']}     ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[1]['lotNumber']}     ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[1]['locationId']}    ${locId1}
    Should Be Equal As Strings    ${resp.json()[1]['storeId']}    ${StoreId}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${InventoryCatalogStatus[1]}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${EncId2}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}
    Should Be Equal As Strings    ${resp.json()[1]['item']['name']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[1]['item']['itemSourceEnum']}    ${itemSourceEnum1}
    Should Be Equal As Strings    ${resp.json()[1]['item']['spCode']}    ${itemEncIds}



JD-TC-Get inventory catalog item by inventory catalog encoded id-UH1

    [Documentation]  Get inventory catalog item by inventory catalog encoded id using invalid encid

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME41}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.first name

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${Name}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${Invalid_inventory_catalog_Id}


JD-TC-Get inventory catalog item by inventory catalog encoded id-UH2

    [Documentation]   Get inventory catalog item by inventory catalog encoded id without login.


    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${EncId2}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get inventory catalog item by inventory catalog encoded id-UH5

    [Documentation]  Get inventory catalog item by inventory catalog encoded id from sa login login.


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${EncId2}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get inventory catalog item by inventory catalog encoded id-UH6

    [Documentation]  Get inventory catalog item by inventory catalog encoded id using another provider

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get inventory catalog item by inventory catalog encoded id  ${encid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${Invalid_inventory_catalog_Id}