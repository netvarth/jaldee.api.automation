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

JD-TC-UpdateItemTax-1

    [Documentation]  SA Update Item Tax SA  ${account_id} - tax name

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
    # Should Be Equal As Strings    ${resp.json()['taxPercentage']}   ${taxPercentage}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}

    ${taxName2}=    FakerLibrary.name

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName2}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax SA  ${account_id}  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName2}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}


JD-TC-UpdateItemTax-2

    [Documentation]  Update Item tax - tax name is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${taxName2}=    FakerLibrary.name

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName2}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName2}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

JD-TC-UpdateItemTax-3

    [Documentation]  Update Item tax - tax name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${empty}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-4

    [Documentation]  Update Item tax - tax code is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${empty}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_CODE}

JD-TC-UpdateItemTax-5

    [Documentation]  Update Item tax - tax cod is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${fake}=    Random Int  min=9999    max=99999

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${fake}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_CODE}

JD-TC-UpdateItemTax-6

    [Documentation]  Update Item tax - type enum is changed 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[1]}  ${taxPercentage}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[1]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}


JD-TC-UpdateItemTax-8

    [Documentation]  Update Item tax - tax percentage is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${taxPercentage2}=     Random Int  min=0  max=200    

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage2}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Item Tax by id  ${itemtax_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['taxName']}         ${taxName}
    Should Be Equal As Strings    ${resp.json()['status']}          ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()['taxTypeEnum']}     ${taxtypeenum[0]}
    Should Be Equal As Strings    ${resp.json()['taxCode']}         ${itemtax_id}

JD-TC-UpdateItemTax-9

    [Documentation]  Update Item tax - tax percentage is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${empty}  cgst=${cgst}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_TAX_PERCENTAGE}

JD-TC-UpdateItemTax-10

    [Documentation]  Update Item tax - cgst is changes

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cgst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst2}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-11

    [Documentation]  Update Item tax - cgst is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${empty}   sgst=${sgst}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_CGST_PERCENTAGE}

JD-TC-UpdateItemTax-12

    [Documentation]  Update Item tax - sgst is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sgst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst2}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-13

    [Documentation]  Update Item tax - sgst is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${empty}   igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_SGST_PERCENTAGE}

JD-TC-UpdateItemTax-14

    [Documentation]  Update Item tax - igst is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${igst2}=     Random Int  min=0  max=200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}  igst=${igst2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemTax-15

    [Documentation]  Update Item tax - igst is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}  igst=${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}         ${INVALID_IGST_PERCENTAGE}

JD-TC-UpdateItemTax-16

    [Documentation]  Update Item tax - without login

    ${resp}=    Update Item Tax SA  ${account_id}  ${taxName}  ${itemtax_id}  ${taxtypeenum[0]}  ${taxPercentage}  cgst=${cgst}   sgst=${sgst}  igst=${igst}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 

