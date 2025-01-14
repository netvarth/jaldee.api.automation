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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122
${invalidstring}     _ad$.sa_
${invalidItem}     sprx-3250dr0-800
@{spItemSource}      RX       Ayur
${originFrom}       NONE
@{deliveryType}     STORE_PICKUP        HOME_DELIVERY
${s_len}            1

*** Test Cases ***

JD-TC-Get Sales Order With Count Filter -1

    [Documentation]   Create a sales Order then try to get sales order count with encId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s
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

# --------------------- ---------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME22}
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

# ------------------------ Create Store ----------------------------------------------------------

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name} 

    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[1]}    walkinOrder=${boolean[1]}   partnerOrder=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

# ---------------------------------------------------------------------------------------------------

# --------------------------- Create SalesOrder Inventory Catalog-InvMgr False ------------------------------------

    ${resp}=  Create SalesOrder Inventory Catalog-InvMgr False   ${store_id}   ${Name}  ${boolean[0]}   onlineSelfOrder=${boolean[1]}  walkInOrder=${boolean[1]}  storePickup=${boolean[1]}  homeDelivery=${boolean[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_Cata_Encid}  ${resp.json()}
# --------------------------------------------------------------------------------------------------------------
# ----------------------------------------  Create Item ---------------------------------------------------

    ${displayName}=     FakerLibrary.name
    ${displayName1}=     FakerLibrary.name
    ${resp}=    Create Item Inventory  ${displayName}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId1}  ${resp.json()}

    ${resp}=    Create Item Inventory  ${displayName1}    
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${itemEncId2}  ${resp.json()}

    ${itemdata}=   FakerLibrary.words    	nb=4

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_id1}  ${resp.json()}
# -------------------------------------------------------------------------------------------------------------------
# -------------------------------- Create SalesOrder Catalog Item-invMgmt False -----------------------------------

    ${price}=    Random Int  min=2   max=40
    ${invCatItem}=     Create Dictionary       encId=${itemEncId2}
    ${Item_details}=  Create Dictionary        spItem=${invCatItem}    price=${price}   


    ${resp}=  Create SalesOrder Catalog Item-invMgmt False      ${SO_Cata_Encid}     ${itemEncId1}     ${price}     ${Item_details}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${SO_itemEncIds}  ${resp.json()[0]}
    Set Suite Variable  ${SO_itemEncIds2}  ${resp.json()[1]}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   generate_firstname
    ${lastName}=    FakerLibrary.last_name
    Set Suite Variable      ${firstName}
    Set Suite Variable      ${lastName}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}${firstName}.${test_mail}

    ${resp}=  AddCustomer  ${primaryMobileNo}  firstName=${firstName}   lastName=${lastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${email}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${primaryMobileNo}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullastName}   Set Variable    ${firstName} ${lastName}
    Set Test Variable  ${fullastName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# --------------------------------------------------------------------------------------------------------

# ----------------------------- Provider take a Sales Order ------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5

    ${Cg_encid}=  Create Dictionary   encId=${SO_Cata_Encid}   
    ${SO_Cata_Encid_List}=  Create List       ${Cg_encid}
    Set Suite Variable  ${SO_Cata_Encid_List}

    ${store}=  Create Dictionary   encId=${store_id}  
    Set Suite Variable  ${store}
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom}  ${items}   store=${store}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}
    # ${s_len}=  Get Length  ${resp.content}

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1


    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${SO_Encid}     ${resp.json()['encId']}

# -----------------------------------------------------------------------------------------------------------------------------------------

# ------------------------------------ Update order status --------------------------------------------------

    ${quantity}=    Random Int  min=20   max=50

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1

    # ${resp}=    Update Order Items    ${SO_Uid}     ${SO_itemEncIds}    ${quantity}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
# ------------------------------------------------------------------------------------------------------------------

# --------------------------------------------- Get Order list -------------------------------------------------------------

    ${resp}=    Get SalesOrder Count     encId-eq=${SO_Encid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}                         
    
JD-TC-Get Sales Order With Count Filter -2

    [Documentation]    Try to get sales order count with uid param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count         uid-eq=${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -3

    [Documentation]    Try to get sales order count with locationId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     locationId-eq=${locId1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -4

    [Documentation]    Try to get sales order count with locationName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${location_name}   ${resp.json()[0]['place']}

    ${resp}=    Get SalesOrder Count     locationName-eq=${location_name}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -5

    [Documentation]    Try to get sales order count with storeId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     storeId-eq=${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get Sales Order With Count Filter -6

    [Documentation]    Try to get sales order count with storeName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     storeName-eq=${Name}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    
JD-TC-Get Sales Order With Count Filter -7

    [Documentation]    Try to get sales order count with orderNum param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     orderNum-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -8

    [Documentation]    Try to get sales order count with rxRefId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     rxRefId-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get Sales Order With Count Filter -9

    [Documentation]    Try to get sales order count with providerConsumerName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     providerConsumerName-eq=${firstName} ${lastName}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -10

    [Documentation]    Try to get sales order count with sorderCatalogId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     sorderCatalogId-eq=${SO_Cata_Encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get Sales Order With Count Filter -11

    [Documentation]    Try to get sales order count with soCatalogName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     soCatalogName-eq=${Name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -12

    [Documentation]    Try to get sales order count with originFrom param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     originFrom-eq=${originFrom}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -13

    [Documentation]    Try to get sales order count with orderType param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     orderType-eq=${bookingChannel[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -14

    [Documentation]    Try to get sales order count with orderStatus param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     orderStatus-eq=${orderStatus[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -15

    [Documentation]    Try to get sales order count with deliveryType param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     deliveryType-eq=${deliveryType[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -16

    [Documentation]    Try to get sales order count with deliveryStatus param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     deliveryStatus-eq=${deliveryStatus[0]} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

    
*** Comments ***
JD-TC-Get Sales Order With Count Filter -17

    [Documentation]    Try to get sales order count with partnerSpAccountId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpAccountId-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -18

    [Documentation]    Try to get sales order count with partnerSpName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpName-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -19

    [Documentation]    Try to get sales order count with partnerSpUserId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpUserId-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -20

    [Documentation]    Try to get sales order count with partnerSpUserName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpUserName-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -21

    [Documentation]    Try to get sales order count with partnerSpRxOwnerId param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpRxOwnerId-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    

JD-TC-Get Sales Order With Count Filter -22

    [Documentation]    Try to get sales order count with partnerSpRxOwnerName param.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get SalesOrder Count     partnerSpRxOwnerName-eq=1   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}                 ${s_len}    
