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

JD-TC-GetStoreListByFilter-1

    [Documentation]  Get Store List By Filter - name filter

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
    Set Suite Variable      ${typeid}   ${resp.json()['id']}

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
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
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
 
    
    ${resp}=    Get store list  name-eq=${Name}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}      ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}     ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${Name}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}          ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}     ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}      ${email_id}


JD-TC-GetStoreListByFilter-2

    [Documentation]  Get Store List By Filter - storeNature filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  storeNature-eq=${storeNature[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id}

JD-TC-GetStoreListByFilter-3

    [Documentation]  Get Store List By Filter - storeCode filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  storeCode-eq=${storeCode2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

JD-TC-GetStoreListByFilter-4

    [Documentation]  Get Store List By Filter - encId filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  encId-eq=${store_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

JD-TC-GetStoreListByFilter-5

    [Documentation]  Get Store List By Filter - city filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  city-eq=${city}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}


JD-TC-GetStoreListByFilter-6

    [Documentation]  Get Store List By Filter - district filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  district-eq=${district}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}

JD-TC-GetStoreListByFilter-7

    [Documentation]  Get Store List By Filter - state filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  state-eq=${State}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}


JD-TC-GetStoreListByFilter-8

    [Documentation]  Get Store List By Filter - country filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  country-eq=${country}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}

JD-TC-GetStoreListByFilter-9

    [Documentation]  Get Store List By Filter - pincode filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  pincode-eq=${pincode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}


JD-TC-GetStoreListByFilter-10

    [Documentation]  Get Store List By Filter - status filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  status-eq=${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}

JD-TC-GetStoreListByFilter-11

    [Documentation]  Get Store List By Filter - filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}


JD-TC-GetStoreListByFilter-12

    [Documentation]  Get Store List By Filter - storeType filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get store list  storeType-eq=${typeid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}      ${accountId}
    Should Be Equal As Strings  ${resp.json()[0]['locationId']}     ${locId1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${Name}
    Should Be Equal As Strings  ${resp.json()[0]['storeNature']}    ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}          ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}     ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}      ${email_id}
    # Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${accountId}
    # Should Be Equal As Strings  ${resp.json()[0]['locationId']}  ${locId1}
    # Should Be Equal As Strings  ${resp.json()[0]['name']}  ${Name2}
    # Should Be Equal As Strings  ${resp.json()[0]['storeNature']}  ${storeNature[2]}
    # Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['number']}  ${PhoneNumber2}
    # Should Be Equal As Strings  ${resp.json()[0]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['emails'][0]}  ${email_id2}

    # Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${accountId}
    # Should Be Equal As Strings  ${resp.json()[1]['locationId']}  ${locId1}
    # Should Be Equal As Strings  ${resp.json()[1]['name']}  ${Name}
    # Should Be Equal As Strings  ${resp.json()[1]['storeNature']}  ${storeNature[0]}
    # Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['number']}  ${PhoneNumber}
    # Should Be Equal As Strings  ${resp.json()[1]['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    # Should Be Equal As Strings  ${resp.json()[1]['emails'][0]}  ${email_id}


JD-TC-GetStoreListByFilter-13

    [Documentation]  Get Store List By Filter - without login

    ${resp}=    Get store list
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}      ${SESSION_EXPIRED}










