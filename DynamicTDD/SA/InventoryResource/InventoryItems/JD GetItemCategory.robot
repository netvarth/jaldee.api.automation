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

JD-TC-GetItemCategory-1

    [Documentation]  SA Get a Item Category.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME263}  ${PASSWORD}
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

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${cat_Id}   ${resp.json()}

    ${resp}=    Get Item Category SA    ${account_id}  ${cat_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${cat_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${Toggle[0]}

JD-TC-GetItemCategory-UH1

    [Documentation]  SA Get a Item Category. - category id is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Category SA    ${account_id}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-GetItemCategory-UH2

    [Documentation]  SA Get a Item Category. - category id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=999  max=9999

    ${resp}=    Get Item Category SA    ${account_id}  ${fake}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Empty   ${resp.content}

JD-TC-GetItemCategory-UH3

    [Documentation]  SA Get a Item Category. - without login

    ${resp}=    Get Item Category SA    ${account_id}  ${cat_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-GetItemCategory-uH4

    [Documentation]  SA Get a Item Category - get from provider side

    ${resp}=  Encrypted Provider Login  ${PUSERNAME263}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Category   ${cat_Id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    