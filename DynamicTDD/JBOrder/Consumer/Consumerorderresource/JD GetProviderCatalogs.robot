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

*** Keywords ***
Get Provider Catalog Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/so/catalog   params=${param}   expected_status=any
    RETURN  ${resp} 

*** Test Cases ***

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
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}
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

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12
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
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}                                  ${boolean[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}                                        ${boolean[0]}
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
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name1}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id2}    ${resp.json()}

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
    Should Be Equal As Strings    ${resp.json()[0]['invMgmt']}                                           ${boolean[0]}
    Should Be Equal As Strings    ${resp.json()[0]['onlineSelfOrder']}                                  ${boolean[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkInOrder']}                                        ${boolean[1]}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}                                       ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                           ${toggle[0]}

JD-TC-Get Provider Catalogs-3

    [Documentation]  consumer side get  catalog using storeEncId


    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  name-eq=${store_id}
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
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${boolean[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                            ${toggle[0]}


        ELSE IF     ${resp.json()[${i}]['encId']}' == '${soc_id2}'      
            Should Be Equal As Strings    ${resp.json()[${i}]['name']}                                           ${Name1}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['encId']}                                  ${store_id}
            Should Be Equal As Strings    ${resp.json()[${i}]['store']['name']}                                   ${Name}
            Should Be Equal As Strings    ${resp.json()[${i}]['accountId']}                                        ${accountId}
            Should Be Equal As Strings    ${resp.json()[${i}]['invMgmt']}                                           ${boolean[0]}
            Should Be Equal As Strings    ${resp.json()[${i}]['onlineSelfOrder']}                                  ${boolean[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['walkInOrder']}                                        ${boolean[1]}
            Should Be Equal As Strings    ${resp.json()[${i}]['location']['id']}                                       ${locId1}
            Should Be Equal As Strings    ${resp.json()[${i}]['status']}                                           ${toggle[0]}
        END
    END



JD-TC-Get Provider Catalogs-UH1

    [Documentation]  Provider create catalog with inventory manager is on and online self order is disable ,walkin order is enabled ,consumer try to get that catalog using name

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME53}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name2}=    FakerLibrary. name
    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name2}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable              ${soc_id3}    ${resp.json()}

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Provider Catalog Filter  name-eq=${Name2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.status_code}    []





