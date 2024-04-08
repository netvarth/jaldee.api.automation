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

JD-TC-UpdateItemHsnSA-1

    [Documentation]  SA Update Item Hsn - updated with same value

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
    Set Suite Variable      ${owner}    ${resp.json()['id']}

    ${hsnCode}=                 Random Int  min=1  max=999
    Set Suite Variable          ${hsnCode}

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${resp}=    Get Item Hsn SA  ${account_id}  ${hsn_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${owner} 
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

    ${resp}=    Update Item Hsn SA  ${account_id}  ${hsn_id}  ${hsnCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Hsn SA  ${account_id}  ${hsn_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${owner} 
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

JD-TC-UpdateItemHsnSA-2

    [Documentation]  SA Update Item Hsn - changed hsn code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${hsnCode2}=                 Random Int  min=999  max=9999

    ${resp}=    Update Item Hsn SA  ${account_id}  ${hsn_id}  ${hsnCode2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Hsn SA  ${account_id}  ${hsn_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode2}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${owner} 
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

JD-TC-UpdateItemHsnSA-3

    [Documentation]  SA Update Item Hsn - empty hsn code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Hsn SA  ${account_id}  ${hsn_id}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Hsn SA  ${account_id}  ${hsn_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${empty}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${owner} 
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

JD-TC-UpdateItemHsnSA-UH1

    [Documentation]  SA Update Item Hsn - without login

    ${resp}=    Update Item Hsn SA  ${account_id}  ${hsn_id}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 
