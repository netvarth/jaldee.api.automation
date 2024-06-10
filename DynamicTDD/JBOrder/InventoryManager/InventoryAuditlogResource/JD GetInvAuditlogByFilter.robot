*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Auditlog 
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

*** Test Cases ***

JD-TC-GetInvAuditlogByFilter-1

    [Documentation]  Create inventory item, add item to inventory catalouge, then verify auditlog.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.File Name
    Set Suite Variable  ${TypeName}
    sleep  02s
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.Last Name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.word
    Set Suite Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}    ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME20}
    Set Suite Variable    ${accountId}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${user_id}  ${resp.json()[0]['id']}
    Set Suite Variable  ${user_firstName}  ${resp.json()[0]['firstName']}
    Set Suite Variable  ${user_lastName}  ${resp.json()[0]['lastName']}

    ${resp}=  Provide Get Store Type By EncId     ${St_Id}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}

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

    ${Store_Name}=    FakerLibrary.last name
    Set Suite Variable    ${Store_Name} 
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Store_Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Store_Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}
    

    #............create inventory item...............
    ${Catalog_Name}=    FakerLibrary.last name
    Set Suite Variable  ${Catalog_Name}
    ${resp}=  Create Inventory Catalog   ${Catalog_Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${encid}  ${resp.json()}

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['catalogName']}    ${Catalog_Name}
    Set Suite Variable  ${invCatalog_id}  ${resp.json()['id']}


    ${resp}=   Get Inventory Auditlog By Filter
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-2

    [Documentation]  Get Inventory Auditlog By account Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    account-eq=${accountId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-3

    [Documentation]  Get Inventory Auditlog By auditType Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditType-eq=${InventoryAuditType[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-4

    [Documentation]  Get Inventory Auditlog By auditContext Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditContext-eq=${InventoryAuditContext[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-5

    [Documentation]  Get Inventory Auditlog By auditLogAction Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditLogAction-eq=${InventoryAuditLogAction[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-6

    [Documentation]  Get Inventory Auditlog By userName Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    userName-eq=${user_firstName}${user_lastName}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-7

    [Documentation]  Get Inventory Auditlog By userId Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    userId-eq=${user_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-8

    [Documentation]  Get Inventory Auditlog By userType Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    userType-eq=${userType[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-9

    [Documentation]  Get Inventory Auditlog By deviceName Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    deviceName-eq=${userType[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-10

    [Documentation]  Get Inventory Auditlog By deviceId Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    deviceId-eq=${userType[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}
  
JD-TC-GetInvAuditlogByFilter-11

    [Documentation]  Get Inventory Auditlog By dateTime Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    dateTime-eq=${userType[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-12

    [Documentation]  Provider Update Inventory catalog, then get inventory auditlog and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Catalog_Name2}=    FakerLibrary.word
    Set Suite Variable    ${Catalog_Name2} 

    ${resp}=  Update Inventory Catalog   ${Catalog_Name2}  ${store_id}   ${encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Inventory Catalog By EncId   ${encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['catalogName']}    ${Catalog_Name2}
    Should Be Equal As Strings    ${resp.json()['storeEncId']}    ${store_id}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${encid}
    Should Be Equal As Strings    ${resp.json()['accountId']}    ${accountId}
    Should Be Equal As Strings    ${resp.json()['storeName']}    ${Store_Name}


    ${resp}=   Get Inventory Auditlog By Filter    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-13

    [Documentation]   Updated Inventory catalog verifing with account Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    account-eq=${accountId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-14

    [Documentation]   Updated Inventory catalog verifing with auditType Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditType-eq=${InventoryAuditType[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-15

    [Documentation]   Updated Inventory catalog verifing with auditContext Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditContext-eq=${InventoryAuditContext[3]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

    Should Be Equal As Strings  ${resp.json()[1]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[1]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[1]['auditLogAction']}       ${InventoryAuditLogAction[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['subject']}    Inventory Catalog Created
    Should Be Equal As Strings  ${resp.json()[1]['description']}    Inventory Catalog Created ${Catalog_Name}
    Should Be Equal As Strings  ${resp.json()[1]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-16

    [Documentation]   Updated Inventory catalog verifing with auditLogAction Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    auditLogAction-eq=${InventoryAuditLogAction[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}

JD-TC-GetInvAuditlogByFilter-17

    [Documentation]   Updated Inventory catalog verifing with userName Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Inventory Auditlog By Filter    userName-eq=${user_firstName}${user_lastName}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}       ${encid}
    Should Be Equal As Strings  ${resp.json()[0]['auditType']}       ${InventoryAuditType[2]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditContext']}       ${InventoryAuditContext[3]} 
    Should Be Equal As Strings  ${resp.json()[0]['auditLogAction']}       ${InventoryAuditLogAction[1]} 
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   ${userType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Inventory Catalog updated
    Should Be Equal As Strings  ${resp.json()[0]['description']}    Inventory Catalog updated ${Catalog_Name2}
    Should Be Equal As Strings  ${resp.json()[0]['userId']}   ${user_id}
