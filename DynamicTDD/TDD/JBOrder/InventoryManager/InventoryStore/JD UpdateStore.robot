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

JD-TC-UpdateStore-1
    [Documentation]  Service Provider Create a store with valid details(store type is PHARMACY)then Update it's name.

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

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME1}
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
    Set Suite Variable  ${email}
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
    Set Suite Variable  ${email2}
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

    ${Name1}=    FakerLibrary.last name

    ${resp}=  Update Store      ${store_id}    ${Name1}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${accountId}
    Should Be Equal As Strings  ${resp.json()['locationId']}  ${locId1}
    Should Be Equal As Strings  ${resp.json()['name']}  ${Name1}
    Should Be Equal As Strings  ${resp.json()['storeTypeEncId']}  ${St_Id}
    Should Be Equal As Strings  ${resp.json()['onlineOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['partnerOrder']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['encId']}  ${store_id}
    Should Be Equal As Strings  ${resp.json()['storeNature']}  ${storeNature[0]}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['number']}  ${PhoneNumber}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${email_id}


JD-TC-UpdateStore-2
    [Documentation]   Update store - without email

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${empty}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    

JD-TC-UpdateStore-3
    [Documentation]   Update store - email id is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email2}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-4
    [Documentation]   Update store - phoneNumber is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${empty}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    

JD-TC-UpdateStore-5
    [Documentation]   Update store - phone number is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber2}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-6
    [Documentation]   Update store - country code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${empty}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${COUNTRYCODE_EMPTY}

JD-TC-UpdateStore-7
    [Documentation]   Update store - country code is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[1]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-8
    [Documentation]   Update store - store code is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${empty}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-9
    [Documentation]   Update store - store code is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${storeCode3}=   FakerLibrary.Random Number
    Set Suite Variable  ${storeCode3} 

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode3}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-10
    [Documentation]   Update store - city is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${empty}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-11
    [Documentation]   Update store - city is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=Thrissur  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-12
    [Documentation]   Update store - district is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${empty}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-13
    [Documentation]   Update store - district is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=Thrissur  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-14
    [Documentation]   Update store - state is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${empty}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-15
    [Documentation]   Update store - state is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=Kerala  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-16
    [Documentation]   Update store - country is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${empty}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-17
    [Documentation]   Update store - country is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=UK  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-18
    [Documentation]   Update store - pincode is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-19
    [Documentation]   Update store - pincode is changed

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=680623
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateStore-20
    [Documentation]   Update store - loc id is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${empty}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${LOCATION_INVALID}

JD-TC-UpdateStore-21
    [Documentation]   Update store - loc id is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int   min=9999  max=99999

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${fake}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_LOCATION_ID}

JD-TC-UpdateStore-22
    [Documentation]   Update store - store Type EncId is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${Name}  ${empty}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_STORE_TYPE_ID}

JD-TC-UpdateStore-23
    [Documentation]   Update store - store Type EncId is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int   min=9999  max=99999

    ${resp}=  Update Store      ${store_id}    ${Name}  ${fake}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_STORE_TYPE_ID}

JD-TC-UpdateStore-24
    [Documentation]   Update store - name is empty

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Store      ${store_id}    ${empty}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${PLEASE_ENTER_NAME}

# JD-TC-UpdateStore-25

#     [Documentation]   Update store - store id is empty

#     ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Update Store      ${empty}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    422
#     Should Be Equal As Strings    ${resp.json()}    

JD-TC-UpdateStore-26
    [Documentation]   Update store - store id is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int   min=9999  max=99999

    ${resp}=  Update Store      ${fake}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_STORE_ID}

JD-TC-UpdateStore-27
    [Documentation]   Update store - without login

    ${resp}=  Update Store      ${store_id}    ${Name}  ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode2}  city=${city}  district=${district}  State=${State}  country=${country}  pincode=${pincode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}