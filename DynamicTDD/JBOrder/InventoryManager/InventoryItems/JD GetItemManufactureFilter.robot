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

JD-TC-GetItemManufactureByFilter-1

    [Documentation]  Get Item Manufacture Filter

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
    Set Suite Variable  ${imf_id}   ${resp.json()['id']}

    ${manufactureName2}=    FakerLibrary.name
    Set Suite Variable  ${manufactureName2}

    ${resp}=  Create Item Manufacture   ${manufactureName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${mf_id2}    ${resp.json()}    

    ${resp}=  Get Item Manufacture By Id   ${mf_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName2}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id2}
    Set Suite Variable  ${imf_id2}   ${resp.json()['id']}

    ${resp}=    Get Item Manufacture Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${imf_id}
    Should Be Equal As Strings    ${resp.json()[1]['manufacturerCode']}    ${mf_id}
    Should Be Equal As Strings    ${resp.json()[1]['manufacturerName']}    ${manufactureName}

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${imf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerCode']}    ${mf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerName']}    ${manufactureName2}

JD-TC-GetItemManufactureByFilter-2

    [Documentation]   Get Item Manufacture Filter - with manufactureCode
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Manufacture Filter  manufactureCode-eq=${mf_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${imf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerCode']}    ${mf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerName']}    ${manufactureName2}


JD-TC-GetItemManufactureByFilter-3

    [Documentation]   Get Item Manufacture Filter - with manufactureName
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Manufacture Filter  manufactureName-eq=${manufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${imf_id}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerCode']}    ${mf_id}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerName']}    ${manufactureName}

JD-TC-GetItemManufactureByFilter-4

    [Documentation]   Get Item Manufacture Filter - with status enable
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Manufacture Filter  status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${imf_id}
    Should Be Equal As Strings    ${resp.json()[1]['manufacturerCode']}    ${mf_id}
    Should Be Equal As Strings    ${resp.json()[1]['manufacturerName']}    ${manufactureName}

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${imf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerCode']}    ${mf_id2}
    Should Be Equal As Strings    ${resp.json()[0]['manufacturerName']}    ${manufactureName2}

JD-TC-GetItemManufactureByFilter-5

    [Documentation]   Get Item Manufacture Filter - with status Disable
 
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Manufacture Filter  status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetItemManufactureByFilter-6

    [Documentation]   Get Item Manufacture Filter - without login

    ${resp}=    Get Item Manufacture Filter  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

    