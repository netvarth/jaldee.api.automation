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

JD-TC-UpdateStoreStatus-1
    [Documentation]  Update Store Status

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

    ${Name}=    FakerLibrary.last name
    Set Suite Variable  ${Name}
    ${storeCode1}=   FakerLibrary.Random Number
    Set Suite Variable  ${storeCode1}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Suite Variable  ${PhoneNumber}
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Suite Variable  ${email_id}

    ${resp}=  Create Store   ${Name}  ${St_Id}    ${locId1}  ${email}     ${PhoneNumber}  ${countryCodes[0]}  storeCode=${storeCode1}
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
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[0]}

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[4]}


JD-TC-UpdateStoreStatus-UH1
    [Documentation]  Update Store Status - inactive to inactive

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[4]}

    ${STORE_ALREADY_IN_STATUS}=  Format String  ${STORE_ALREADY_IN_STATUS}    Deactive

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${STORE_ALREADY_IN_STATUS}


JD-TC-UpdateStoreStatus-2
    [Documentation]  Update Store Status - inactive to active

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[4]}

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[0]}

JD-TC-UpdateStoreStatus-UH2
    [Documentation]  Update Store Status - active to active

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Store ByEncId   ${store_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['status']}    ${LoanApplicationStatus[0]}

    ${STORE_ALREADY_IN_STATUS}=  Format String  ${STORE_ALREADY_IN_STATUS}    Active

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${STORE_ALREADY_IN_STATUS}

JD-TC-UpdateStoreStatus-UH3
    [Documentation]  Update Store Status - where store is invalid

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=9999  max=99999

    ${resp}=   Update store status  ${fake}  ${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_STORE_ID}

JD-TC-UpdateStoreStatus-UH4
    [Documentation]  Update Store Status - without login

    ${resp}=   Update store status  ${store_id}  ${LoanApplicationStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}