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
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-UpdateItemManufacture-1

    [Documentation]  SA Update Item Manufacture - manufacture Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME269}  ${PASSWORD}
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

    ${manufacturerName2}=     FakerLibrary.name

    ${resp}=    Update Item manufacturer SA  ${account_id}  ${manufacturerName2}  ${mft_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item manufacturer SA  ${account_id}  ${mft_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}      ${mft_id}
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}      ${manufacturerName2}
    Should Be Equal As Strings    ${resp.json()['status']}               ${toggle[0]}










JD-TC-UpdateItemManufacture-2

    [Documentation]  SA Update Item Manufacture - manufacture Name is empty 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Manufacturer name 

    ${resp}=    Update Item manufacturer SA  ${account_id}  ${empty}  ${mft_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemManufacture-3

    [Documentation]  SA Update Item Manufacture - manufacture Code is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Manufacturer code

    ${resp}=    Update Item manufacturer SA  ${account_id}  ${manufacturerName}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}


JD-TC-UpdateItemManufacture-4

    [Documentation]  SA Update Item Manufacture - manufacture Code is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=999  max=9999

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Manufacturer code

    ${resp}=    Update Item manufacturer SA  ${account_id}  ${manufacturerName}  ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_FIELD}

JD-TC-UpdateItemManufacture-5

    [Documentation]  SA Update Item Manufacture - without login

    ${resp}=    Update Item manufacturer SA  ${account_id}  ${manufacturerName}  ${mft_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200