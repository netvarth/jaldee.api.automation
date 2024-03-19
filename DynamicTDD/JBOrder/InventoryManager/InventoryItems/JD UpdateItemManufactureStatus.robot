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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-UpdateItemManufactureStatus-1

    [Documentation]  Update Item Manufacture Status

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${manufactureName}=    FakerLibrary.name
    Set Suite Variable  ${manufactureName}

    ${resp}=  Create Item Manufacture   ${manufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${mf_id}    ${resp.json()}    

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[0]}

    ${resp}=    Update Item Manufacture Status  ${mf_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[1]}

JD-TC-UpdateItemManufactureStatus-2

    [Documentation]  Update Item Manufacture Status - Disable to Disable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[1]}

    ${resp}=    Update Item Manufacture Status  ${mf_id}  ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateItemManufactureStatus-3

    [Documentation]  Update Item Manufacture Status - Disable to Enable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[1]}

    ${resp}=    Update Item Manufacture Status  ${mf_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[0]}

JD-TC-UpdateItemManufactureStatus-4

    [Documentation]  Update Item Manufacture Status - Enable to Enable

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}
    Set Suite Variable            ${imf_id}   ${resp.json()['id']}
    Should Be Equal As Strings    ${resp.json()['status']}              ${toggle[0]}

    ${resp}=    Update Item Manufacture Status  ${mf_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemManufactureStatus-5

    [Documentation]  Update Item Manufacture Status - without login

    ${resp}=    Update Item Manufacture Status  ${mf_id}  ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}         ${SESSION_EXPIRED}