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

JD-TC-UpdateItemTaxStatusSA-1

    [Documentation]  SA Update Item Tax Status

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

    ${taxName}=    FakerLibrary.name
    ${taxPercentage}=     Random Int  min=0  max=200
    ${cgst}=     Random Int  min=0  max=200
    ${sgst}=     Random Int  min=0  max=200
    ${igst}=     Random Int  min=0  max=200
    Set Suite Variable      ${taxName}
    Set Suite Variable      ${taxPercentage}
    Set Suite Variable      ${cgst}
    Set Suite Variable      ${sgst}
    Set Suite Variable      ${igst}

    ${resp}=    Create Item Tax SA  ${account_id}  ${taxName}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${itemtax_id}  ${resp.json()}

    ${resp}=    Get Item Tax SA  ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}

    ${resp}=    Update Item Tax Status SA   ${account_id}  ${itemtax_id}   ${Toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax SA  ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}


JD-TC-UpdateItemTaxStatusSA-UH1

    [Documentation]  SA Update Item Tax Status - disable to disable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Tax SA    ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}

    ${resp}=    Update Item Tax Status SA   ${account_id}  ${itemtax_id}   ${Toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemTaxStatusSA-UH2

    [Documentation]  SA Update Item Tax Status - disable to enable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Tax SA    ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[1]}

    ${resp}=    Update Item Tax Status SA   ${account_id}  ${itemtax_id}   ${Toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax SA    ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}

JD-TC-UpdateItemTaxStatusSA-UH3

    [Documentation]  SA Update Item Tax Status - enable to enable

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Tax SA    ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}

    ${resp}=    Update Item Tax Status SA   ${account_id}  ${itemtax_id}   ${Toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-UpdateItemTaxStatusSA-UH4

    [Documentation]  SA Update Item Tax Status - without login

    ${resp}=    Update Item Tax Status SA   ${account_id}  ${itemtax_id}   ${Toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 
