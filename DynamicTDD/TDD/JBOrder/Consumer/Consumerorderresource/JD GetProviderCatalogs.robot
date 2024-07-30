
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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Test Cases ***


*** Comments ***
JD-TC-Get Provider Catalogs-1

    [Documentation]  Provider create catalog ,consumer side get that catalog

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME53}
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
    Set Suite Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+302187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id1}    ${resp.json()}

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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get Provider Catalog Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                           ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                  ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                   ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}                                           ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}                                  ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}                                        ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                       ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                            ${toggle[0]}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get Provider Catalogs-2

    [Documentation]  Provider create catalog where onlineSelfOrder and walkin order is on  ,consumer side get that catalog using name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.first name
    Set Suite Variable    ${Name1}
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name1}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id2}    ${resp.json()}


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  name-eq=${Name1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                           ${Name1}
    Should Be Equal As Strings    ${resp.json()[0]['store']['encId']}                                  ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['store']['name']}                                   ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                        ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}                                           ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}                                  ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}                                        ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                       ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                           ${toggle[0]}

JD-TC-Get Provider Catalogs-3

    [Documentation]  consumer side get  catalog using storeEncId


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  storeEncId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    2
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${soc_id1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF   '${resp.json()[${i}]['encId']}' == '${soc_id2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END

JD-TC-Get Provider Catalogs-4

    [Documentation]  consumer side get  catalog using storeName


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  storeName-eq=${Name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    2
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${soc_id1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${soc_id2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END

JD-TC-Get Provider Catalogs-5

    [Documentation]  consumer side get  catalog using status


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    2
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${soc_id1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${soc_id2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END

JD-TC-Get Provider Catalogs-UH1

    [Documentation]  consumer side get  catalog using inventory management on case


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  invMgmt-eq= ${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []


JD-TC-Get Provider Catalogs-UH2

    [Documentation]  Provider create catalog with inventory manager is off and online self order is disable ,walkin order is enabled ,consumer try to get that catalog using name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name2}=    FakerLibrary. name
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name2}  ${boolean[0]}   onlineSelfOrder=${boolean[0]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id3}    ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  name-eq=${Name2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}   []

JD-TC-Get Provider Catalogs-6

    [Documentation]  Provider create catalog where inventory manager is on with online sales order is enabled,another one inventory is false and online sales order is disabled and next is inventory is off and online sales order is on,consumer side get that catalog

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()[0]['encId']}


    ${accountId52}=  get_acc_id  ${HLPUSERNAME52}
    Set Suite Variable    ${accountId52} 


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

    ${Name-of-store}=    FakerLibrary.last name
    Set Suite Variable    ${Name-of-store}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187749
    Set Test Variable  ${email_id}  ${Name-of-store}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name-of-store}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id1}  ${resp.json()}

    ${Name}=    FakerLibrary.first name
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid}  ${resp.json()}
    ${inv_cat_encid1}=  Create List  ${inv_cat_encid}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr True   ${store_id1}  ${Name-of-store}  ${boolean[1]}  ${inv_cat_encid1}  onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sa_catlog_id1}  ${resp.json()}

    ${Name3}=    FakerLibrary. name
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}   ${Name3}  ${boolean[0]}   onlineSelfOrder=${boolean[0]}  walkInOrder=${boolean[1]}   storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${sa_catlog_id2}    ${resp.json()}

    ${Name4}=    FakerLibrary. name
    Set Suite Variable              ${Name4}
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}   ${Name4}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${sa_catlog_id3}    ${resp.json()}


# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo1}    Generate random string    10    123456798
    ${primaryMobileNo1}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo1}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo1}    ${accountId52}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo1}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo1}     ${accountId52}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo1}    ${accountId52}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get Provider Catalog Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    2
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${sa_catlog_id1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                            ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                    ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId52}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${sa_catlog_id3}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name4}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId52}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END


    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get Provider Catalogs-7

    [Documentation]  user create catalog then consumer try to acess all catalogs of main provider

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word   
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}



     
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

    ${Name5}=    FakerLibrary. name
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id1}   ${Name5}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  courierService=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${sa_catlog_id4}    ${resp.json()}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo1}    ${accountId52}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get Provider Catalog Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings    ${len}    3
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['encId']}' == '${sa_catlog_id1}'  
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                            ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                    ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId52}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF     '${resp.json()[${i}]['encId']}' == '${sa_catlog_id3}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name4}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId52}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}

        ELSE IF     '${resp.json()[${i}]['encId']}' == '${sa_catlog_id4}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name5}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name-of-store}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId52}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${bool[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${bool[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END


    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200







