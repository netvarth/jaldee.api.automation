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
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122

*** Test Cases ***

JD-TC-GetStoreCountByFilter-1
    [Documentation]  Get Store Count By Filter - name filter

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id}    ${resp.json()}

    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Store Type   ${TypeName1}    ${storeNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${St_Id1}    ${resp.json()}

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
    Set Suite Variable      ${typeid}   ${resp.json()['id']}

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME2}
    Set Suite Variable    ${accountId} 

    ${resp}=  Provider Get Store Type By EncId     ${St_Id}  
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=   Get Location ById  ${locId1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${pincode}     ${resp.json()['pinCode']}
    Set Suite Variable   ${city}     ${resp.json()['place']}

    ${resp}=    Get LocationsByPincode  ${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${district}     ${resp.json()[0]['PostOffice'][0]['District']}
    Set Suite Variable   ${State}     ${resp.json()[0]['PostOffice'][0]['State']}
    Set Suite Variable   ${country}     ${resp.json()[0]['PostOffice'][0]['Country']}

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}
    ${storeCode1}=   FakerLibrary.Random Number
    Set Suite Variable  ${storeCode1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${PhoneNumber}
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Suite Variable  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode1}   city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}         ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}        ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}              ${Name}
    Should Be Equal As Strings  ${resp.json()['city']}              ${city}
    Should Be Equal As Strings  ${resp.json()['district']}          ${district}
    # Should Be Equal As Strings  ${resp.json()['State']}             ${State}
    Should Be Equal As Strings  ${resp.json()['country']}           ${country}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}    ${St_Id}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}       ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}       ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}             ${store_id}
    Should Be Equal As Strings  ${resp.json()['storeNature']}       ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}         ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}         ${email_id}

    ${Name2}=    FakerLibrary.last name
    Set Suite Variable  ${Name2}
    ${PhoneNumber2}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${PhoneNumber2}
    Set Test Variable  ${email_id2}  ${Name2}${PhoneNumber2}.${test_mail}
    ${email2}=  Create List  ${email_id2}
    Set Suite Variable  ${email_id2}
    ${storeCode2}=   FakerLibrary.Random Number
    Set Suite Variable  ${storeCode2}   

    ${resp}=  Create Store   ${Name2}  ${St_Id2}    ${locId1}  ${email2}     ${PhoneNumber2}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id2}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}         ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}        ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}              ${Name2}
    Should Be Equal As Strings  ${resp.json()['city']}              ${city}
    Should Be Equal As Strings  ${resp.json()['district']}          ${district}
    # Should Be Equal As Strings  ${resp.json()['State']}             ${State}
    Should Be Equal As Strings  ${resp.json()['country']}           ${country}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}    ${St_Id2}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}       ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}       ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}      ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}             ${store_id2}
    Should Be Equal As Strings  ${resp.json()['storeNature']}       ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}         ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}         ${email_id2}
    Should Be Equal As Strings  ${resp.json()['status']}            ${LoanApplicationStatus[0]}
    
    ${resp}=    Get store Count  name-eq=${Name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-GetStoreCountByFilter-2
    [Documentation]  Get Store Count By Filter - storeNature filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  storeNature-eq=${storeNature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-GetStoreCountByFilter-3
    [Documentation]  Get Store Count By Filter - storeCode filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  storeCode-eq=${storeCode2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-GetStoreCountByFilter-4
    [Documentation]  Get Store Count By Filter - encId filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  encId-eq=${store_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      1

JD-TC-GetStoreCountByFilter-5
    [Documentation]  Get Store Count By Filter - city filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  city-eq=${city}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2


JD-TC-GetStoreCountByFilter-6
    [Documentation]  Get Store Count By Filter - district filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  district-eq=${district}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2

JD-TC-GetStoreCountByFilter-7
    [Documentation]  Get Store Count By Filter - state filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  state-eq=${state}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2


JD-TC-GetStoreCountByFilter-8
    [Documentation]  Get Store Count By Filter - country filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  country-eq=${country}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2

JD-TC-GetStoreCountByFilter-9
    [Documentation]  Get Store Count By Filter - pincode filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  pincode-eq=${pincode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2


JD-TC-GetStoreCountByFilter-10
    [Documentation]  Get Store Count By Filter - status filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  status-eq=${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2

JD-TC-GetStoreCountByFilter-11
    [Documentation]  Get Store Count By Filter - filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2


JD-TC-GetStoreCountByFilter-12
    [Documentation]  Get Store Count By Filter - storeType filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store Count  storeType-eq=${typeid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}      2


JD-TC-GetStoreCountByFilter-13
    [Documentation]  Get Store Count By Filter - without login

    ${resp}=    Get store Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}      ${SESSION_EXPIRED}