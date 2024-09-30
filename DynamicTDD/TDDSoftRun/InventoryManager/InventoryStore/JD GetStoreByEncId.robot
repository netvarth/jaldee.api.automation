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

JD-TC-GetStoreByEncid-1

    [Documentation]  Service Provider Create a store with valid details(store type is PHARMACY)then try to get by encid.

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME1}
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
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}  ${St_Id}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}  ${store_id}
    Should Be Equal As Strings  ${resp.json()['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${email_id}

JD-TC-GetStoreByEncid-2

    [Documentation]  Service Provider Create a store with valid details(store type is LAB)then try to get by encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id1}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id1}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}  ${St_Id1}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}  ${store_id1}
    Should Be Equal As Strings  ${resp.json()['storeNature']}  ${storeNature[1]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${email_id}

JD-TC-GetStoreByEncid-3

    [Documentation]  Service Provider Create a store with valid details(store type is RADIOLOGY)then try to get by encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}

    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${PhoneNumber}

    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Suite Variable  ${email}

    ${resp}=  Create Store   ${Name}  ${St_Id2}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${store_id2}  ${resp.json()}

    ${resp}=    Get Store ByEncId   ${store_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}  ${St_Id2}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}  ${store_id2}
    Should Be Equal As Strings  ${resp.json()['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${email_id}

JD-TC-GetStoreByEncid-4

    [Documentation]   try to get by invalid encid.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Store ByEncId   ${invalidNum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${INVALID_STORE_ID}

