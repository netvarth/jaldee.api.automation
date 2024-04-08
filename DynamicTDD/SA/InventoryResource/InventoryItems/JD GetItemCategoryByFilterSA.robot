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

JD-TC-GetItemCategoryFilter-1

    [Documentation]  SA Get a Item Category filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
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

    ${categoryName2}=    FakerLibrary.name
    Set Suite Variable  ${categoryName2}

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${cat_Id2}   ${resp.json()}

    ${resp}=    Get Item Category SA    ${account_id}  ${cat_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${cat_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${Toggle[0]}

    ${resp}=    Get Item Category By Filter SA   ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${cat_Id2}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}          ${Toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['categoryCode']}    ${cat_Id}
    Should Be Equal As Strings    ${resp.json()[1]['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[1]['status']}          ${Toggle[0]}

JD-TC-GetItemCategoryFilter-2

    [Documentation]  SA Get a Item Category filter - status

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Category By Filter SA   ${account_id}  status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-GetItemCategoryFilter-3

    [Documentation]  SA Get a Item Category filter - category code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Category By Filter SA   ${account_id}  categoryCode-eq=${cat_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${cat_Id}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}          ${Toggle[0]}

JD-TC-GetItemCategoryFilter-4

    [Documentation]  SA Get a Item Category filter - categoryName

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Category By Filter SA   ${account_id}  categoryName-eq=${categoryName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${cat_Id2}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}          ${Toggle[0]}

JD-TC-GetItemCategoryFilter-5

    [Documentation]  SA Get a Item Category filter - without login

    ${resp}=    Get Item Category By Filter SA   ${account_id} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 