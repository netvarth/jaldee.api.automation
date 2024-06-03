*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetItemManufactureCountByFilter-1

    [Documentation]  SA Get a Item Manufacture Count By Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME305}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${manufacturerName}=     FakerLibrary.name
    Set Suite Variable      ${manufacturerName}

    ${resp}=    Create Item manufacturer SA  ${account_id}  ${manufacturerName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${mft_id}   ${resp.json()}

    ${resp}=    Get Item manufacturer SA  ${account_id}  ${mft_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}      ${mft_id}
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}      ${manufacturerName}
    Should Be Equal As Strings    ${resp.json()['status']}               ${toggle[0]}

    ${resp}=    Get Item manufacturer Count By Filter SA  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}     1


JD-TC-GetItemManufactureCountByFilter-2

    [Documentation]  SA Get Item manufacturer Count By Filter SA - status

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item manufacturer Count By Filter SA   ${account_id}  status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    0

JD-TC-GetItemManufactureCountByFilter-3

    [Documentation]  SA Get Item manufacturer Count By Filter SA - manufacture Code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item manufacturer Count By Filter SA   ${account_id}  manufacturerCode-eq=${mft_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}            1

JD-TC-GetItemManufactureCountByFilter-4

    [Documentation]  SA Get Item manufacturer Count By Filter SA - manufacturer Code                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               eCode

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item manufacturer Count By Filter SA   ${account_id}  manufacturerName-eq=${manufacturerName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}            1

JD-TC-GetItemManufactureCountByFilter-5

    [Documentation]  SA Get Item manufacturer Count By Filter SA - without login

    ${resp}=    Get Item manufacturer Count By Filter SA   ${account_id} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 