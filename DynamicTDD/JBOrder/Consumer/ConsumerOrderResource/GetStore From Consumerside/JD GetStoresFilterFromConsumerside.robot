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

*** Variables ***
${minSaleQuantity}  1
${maxSaleQuantity}   50

*** Test Cases ***

JD-TC-Get Store Filter-1

    [Documentation]  Get store filter from consumer side

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep   02s
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


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME1}
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

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${bool[1]}    walkinOrder=${bool[1]}   partnerOrder=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locationName}  ${resp.json()['locationName']}
    Set Suite Variable  ${storeTypeId}  ${resp.json()['storeTypeId']}
    Set Suite Variable  ${refNumber}  ${resp.json()['refNumber']}
    Set Suite Variable  ${id}  ${resp.json()['id']}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${PH_Number}    Random Number          digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   FakerLibrary.first_name
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
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=    Get stores filter     accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                                ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []

JD-TC-Get Store Filter-2

    [Documentation]  Get Store Filter-using name 

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   name-eq=${Name} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                                ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []
JD-TC-Get Store Filter-3

    [Documentation]  Get Store Filter-using storeNature 

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter      accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   storeNature-eq=${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                               ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []





JD-TC-Get Store Filter-4

    [Documentation]  Get Store Filter-using storeCode 

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   storeCode-eq=${Name}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Get Store Filter-5

    [Documentation]  Get Store Filter-using storeType 

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   storeType-eq=${St_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}                                              []


JD-TC-Get Store Filter-6

    [Documentation]  Get Store Filter   using status

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   status-eq=${InventoryCatalogStatus[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                               ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []



JD-TC-Get Store Filter-7

    [Documentation]  Get Store Filter   using encId

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   encId-eq=${store_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                                ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []

JD-TC-Get Store Filter-8

    [Documentation]  Get Store Filter   using walkinOrder

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   walkinOrder-eq=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                                ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []

JD-TC-Get Store Filter-9

    [Documentation]  Get Store Filter   using partnerOrder

    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}   partnerOrder-eq=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                                ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []



JD-TC-Get Store Filter-10

    [Documentation]  create 2 store from provider side (one is online enabled ,one is online disabled)and get items from consumer side

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Store Type By Filter     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep   02s
    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}
# -------------------------------- Create store type -----------------------------------
    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}
    sleep  02s
    ${TypeName1}=    FakerLibrary.name
    Set Test Variable  ${TypeName1}

    # ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable    ${St_Id1}    ${resp.json()}
    sleep  02s
    ${TypeName2}=    FakerLibrary.name
    Set Test Variable  ${TypeName2}

    ${resp}=  Create Store Type   ${TypeName2}    ${storeNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id2}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${PUSERNAME104}
    Set Test Variable    ${accountId} 

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
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+208187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${boolean[0]}    walkinOrder=${bool[1]}   partnerOrder=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id}  ${resp.json()}

    ${Name1}=    FakerLibrary.first name
    Set Test Variable    ${Name1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+208187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name1}  ${St_Id2}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}   onlineOrder=${bool[1]}    walkinOrder=${bool[1]}   partnerOrder=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${store_id1}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${locationName}  ${resp.json()['locationName']}
    Set Test Variable  ${storeTypeId}  ${resp.json()['storeTypeId']}
    Set Test Variable  ${refNumber}  ${resp.json()['refNumber']}
    Set Test Variable  ${id}  ${resp.json()['id']}

 
# -------------------------------- Add a provider Consumer -----------------------------------

    ${PH_Number}    Random Number          digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${primaryMobileNo}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${Test NAME} - ${TEST NAME} - ${primaryMobileNo}${\n}
    ${firstName}=   FakerLibrary.first_name
    ${lastName}=    FakerLibrary.last_name
    Set Test Variable      ${firstName}
    Set Test Variable      ${lastName}  
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
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=    Get stores filter       accountId-eq=${accountId}   onlineOrder-eq=${bool[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}                                              ${id}
    Should Be Equal As Strings    ${resp.json()[0]['accountId']}                                            ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['locationId']}                                                      ${locId1}
    Should Be Equal As Strings    ${resp.json()[0]['locationName']}                                                      ${locationName}
    Should Be Equal As Strings    ${resp.json()[0]['name']}                                              ${Name1}
    Should Be Equal As Strings    ${resp.json()[0]['onlineOrder']}                                           ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['walkinOrder']}                                             ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['partnerOrder']}                                            ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['storeInChargeId']}                                            0
    Should Be Equal As Strings    ${resp.json()[0]['encId']}                                                      ${store_id1}
    Should Be Equal As Strings    ${resp.json()[0]['storeNature']}                                              ${storeNature[2]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}                                              ${InventoryCatalogStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['storeTypeId']}                                                 ${storeTypeId}
    Should Be Equal As Strings    ${resp.json()[0]['refNumber']}                                               ${refNumber}
    Should Be Equal As Strings    ${resp.json()[0]['uploadedDocuments']}                                           []


