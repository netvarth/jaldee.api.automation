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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_
@{spItemSource}      RX       Ayur
${originFrom}       NONE

*** Keywords ***
Create Sales Order

    [Arguments]  ${SO_Catalog_Id}   ${Pro_Con}   ${OrderFor}   ${originFrom}    ${catItemEncId}   ${quantity}
    ${Cg_encid}=  Create Dictionary   encId=${SO_Catalog_Id}   
    ${PC}=  Create Dictionary   id=${Pro_Con}   
    ${OrderFor}=  Create Dictionary   id=${OrderFor}   

    ${item}=  Create Dictionary   catItemEncId=${catItemEncId}    quantity=${quantity}
    ${items}=   Create List    ${item} 
    ${data}=  Create Dictionary   catalog=${Cg_encid}    providerConsumer=${PC}    orderFor=${OrderFor}   originFrom=${originFrom}      items=${items}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/sorder   data=${data}  expected_status=any
    RETURN  ${resp} 

Update Order Items

    [Arguments]   ${orderEncId}     ${catItemEncId}    ${quantity}

    ${item}=  Create Dictionary   catItemEncId=${catItemEncId}    quantity=${quantity}
    ${data}=   Create List    ${item} 
    # ${data}=  Create Dictionary        items=${items}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/sorder/${orderEncId}/changeitems   data=${data}  expected_status=any
    RETURN  ${resp} 

Get Sales Order
    [Arguments]  ${orderEncId}      
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/sorder/${orderEncId}    expected_status=any
    RETURN  ${resp} 

Update SalesOrder Status

    [Arguments]  ${orderEncId}   ${status}   
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/sorder/${orderEncId}/${status}   expected_status=any
    RETURN  ${resp} 

Get SalesOrder List
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/sorder/item   params=${param}   expected_status=any
    RETURN  ${resp} 

Get SalesOrder Count
    [Arguments]  &{param}    
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/sorder/item/count   params=${param}   expected_status=any
    RETURN  ${resp} 
    
*** Test Cases ***

JD-TC-Create Sales Order-1

    [Documentation]   Create a sales Order with Valid Details.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
# --------------------- Create Store Type from sa side -------------------------------
    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}
    sleep  02s

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['name']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${St_Id}
# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLMUSERNAME16}
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

# ------------------------ Create Store ----------------------------------------------------------

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr False ------------------------------------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}
# --------------------------------------------------------------------------------------------------------------


    ${displayName}=     FakerLibrary.name

    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}

# -------------------------------- Create SalesOrder Catalog Item-invMgmt False -----------------------------------

    ${price}=    Random Int  min=2   max=40

    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}         
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}

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

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${resp}=    Create Sales Order    ${SO_Cata_Encid}   ${cid}   ${cid}   ${originFrom}    ${SO_itemEncIds}   ${quantity}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()}

    ${resp}=    Get Sales Order    ${SO_itemEncIds}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}   ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}   ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}   ${store_id}

    Should Be Equal As Strings    ${resp.json()['catalog']['name']}   ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog']['encId']}   ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog']['invMgmt']}   ${bool[0]}

    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}   ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}   ${firstName} ${lastName}

    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}
    Should Be Equal As Strings    ${resp.json()['accountId']}   ${accountId}

