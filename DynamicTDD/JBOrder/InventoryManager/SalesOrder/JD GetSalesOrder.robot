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

*** Test Cases ***

JD-TC-Get Sales Order-1

    [Documentation]   Create a sales Order with Valid Details then Get sales order by encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME7}
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
    Set Suite Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
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

    ${netTotal}=  Evaluate  ${price}*${quantity}
    ${netTotal}=  Convert To Number  ${netTotal}   1


    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['accountId']}                                       ${accountId}
    Should Be Equal As Strings    ${resp.json()['location']['id']}                                  ${locId1}
    Should Be Equal As Strings    ${resp.json()['store']['name']}                                   ${Name}
    Should Be Equal As Strings    ${resp.json()['store']['encId']}                                  ${store_id}

    Should Be Equal As Strings    ${resp.json()['catalog'][0]['name']}                                 ${Name}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['encId']}                                ${SO_Cata_Encid}
    Should Be Equal As Strings    ${resp.json()['catalog'][0]['invMgmt']}                              ${bool[0]}

    Should Be Equal As Strings    ${resp.json()['providerConsumer']['id']}                          ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['id']}                                  ${cid}
    Should Be Equal As Strings    ${resp.json()['orderFor']['name']}                                ${firstName} ${lastName}

    Should Be Equal As Strings    ${resp.json()['orderType']}                                       ${bookingChannel[0]}
    Should Be Equal As Strings    ${resp.json()['orderStatus']}                                     ${orderStatus[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryType']}                                    ${deliveryType[0]}
    Should Be Equal As Strings    ${resp.json()['deliveryStatus']}                                  ${deliveryStatus[0]}
    Should Be Equal As Strings    ${resp.json()['originFrom']}                                      ${originFrom}

    Should Be Equal As Strings    ${resp.json()['orderNum']}                                        1
    Should Be Equal As Strings    ${resp.json()['orderRef']}                                        1
    Should Be Equal As Strings    ${resp.json()['deliveryDate']}                                    ${DAY1}

    Should Be Equal As Strings    ${resp.json()['contactInfo']['phone']['number']}                  ${primaryMobileNo}
    Should Be Equal As Strings    ${resp.json()['contactInfo']['email']}                            ${email}

    Should Be Equal As Strings    ${resp.json()['itemCount']}                                       1
    Should Be Equal As Strings    ${resp.json()['netTotal']}                                        ${netTotal}
    Should Be Equal As Strings    ${resp.json()['taxTotal']}                                        0.0
    Should Be Equal As Strings    ${resp.json()['discountTotal']}                                   0.0
    Should Be Equal As Strings    ${resp.json()['jaldeeCouponTotal']}                               0.0
    Should Be Equal As Strings    ${resp.json()['providerCouponTotal']}                             0.0
    Should Be Equal As Strings    ${resp.json()['netRate']}                                         ${netTotal}
    Should Be Equal As Strings    ${resp.json()['cgstTotal']}                                       0.0

    Should Be Equal As Strings    ${resp.json()['sgstTotal']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['gst']}                                       0.0
    Should Be Equal As Strings    ${resp.json()['cessTotal']}                                       0.0
# -----------------------------------------------------------------------------------------------------------------------------------------

JD-TC-Get Sales Order-2

    [Documentation]   Create a sales Order with billingAddress , homeDeliveryAddress , notes , notesForCustomer details then verify all the detiles.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${quantity}=    Random Int  min=2   max=5
    ${items}=  Create Dictionary   catItemEncId=${SO_itemEncIds}    quantity=${quantity}   catItemBatchEncId=${SO_itemEncIds}

    ${primaryMobileNo1}    Generate random string    10    123456789
    Set Suite Variable  ${primaryMobileNo1}

    ${bill_Phone1}=   Create Dictionary   countryCode=${countryCodes[0]}           number=${primaryMobileNo1}

    ${contactInfo1}=   Create Dictionary    phone=${bill_Phone1}         email=${email_id}      
    Set Suite Variable  ${contactInfo1}

    ${city}=   FakerLibrary.state
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address

    ${homeDeliveryAddress1}=   Create Dictionary    phone=${bill_Phone1}   firstName=${firstName}      lastName=${lastName}       email=${email_id}      address=${address}    city=${city}   postalCode=${postcode}     landMark=${address}
    Set Suite Variable  ${homeDeliveryAddress1}

    ${billingAddress1}=   Create Dictionary    phone=${bill_Phone1}   firstName=${firstName}      lastName=${lastName}       email=${email_id}      address=${address}    city=${city}   postalCode=${postcode}     landMark=${address}

    ${note}=  FakerLibrary.name
    ${store}=  Create Dictionary   encId=${store_id}  

    ${resp}=    Create Sales Order    ${SO_Cata_Encid_List}   ${cid}   ${cid}   ${originFrom}    ${items}    store=${store}   billingAddress=${billingAddress1}     homeDeliveryAddress=${homeDeliveryAddress1}     notes=${note}      notesForCustomer=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${SO_Uid}  ${resp.json()}

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                           ${SO_Uid}
    Should Be Equal As Strings    ${resp.json()['notes']}                                       ${note}
    Should Be Equal As Strings    ${resp.json()['notesForCustomer']}                                  ${note}

    Should Be Equal As Strings    ${resp.json()['billingAddress']['firstName']}                                   ${firstName}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['lastName']}                                  ${lastName}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['email']}                                  ${email_id}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['address']}                                  ${address}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['city']}                                  ${city}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['postalCode']}                                  ${postcode}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['landMark']}                                  ${address}
    Should Be Equal As Strings    ${resp.json()['billingAddress']['phone']['countryCode']}                                  ${countryCodes[0]} 
    Should Be Equal As Strings    ${resp.json()['billingAddress']['phone']['number']}                                  ${primaryMobileNo1} 

    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['firstName']}                                   ${firstName}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['lastName']}                                  ${lastName}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['email']}                                  ${email_id}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['address']}                                  ${address}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['city']}                                  ${city}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['postalCode']}                                  ${postcode}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['landMark']}                                  ${address}
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['phone']['countryCode']}                                  ${countryCodes[0]} 
    Should Be Equal As Strings    ${resp.json()['homeDeliveryAddress']['phone']['number']}                                  ${primaryMobileNo1} 

JD-TC-Get Sales Order-3

    [Documentation]   where uid is inv

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random int  min=1  max=999

    ${resp}=    Get Sales Order    ${inv}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_ORDER_ID}


JD-TC-Get Sales Order-4

    [Documentation]   without login

    ${resp}=    Get Sales Order    ${SO_Uid}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}