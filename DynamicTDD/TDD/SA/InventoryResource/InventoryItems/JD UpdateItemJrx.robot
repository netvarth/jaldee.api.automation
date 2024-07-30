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

JD-TC-UpdateItemJrx-1

    [Documentation]  Update Item Jrx item name updated - item name updated

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

    ${hsnCode}=                 Random Int  min=1  max=999
    Set Suite Variable          ${hsnCode}

    ${resp}=    Create Item Hsn SA  ${account_id}  ${hsnCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${hsn_id}      ${resp.json()}

    ${itemName}=        FakerLibrary.name
    ${description}=     FakerLibrary.sentence
    ${sku}=             FakerLibrary.name
    Set Suite Variable  ${itemName}
    Set Suite Variable  ${description}
    Set Suite Variable  ${sku}

    ${hsn}=     Create Dictionary    hsnCode=${hsnCode}

    ${resp}=    Create Item Jrx   ${itemName}  description=${description}  sku=${sku}  hsnCode=${hsn}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jrxid}    ${resp.json()}

    ${resp}=    Get Item Jrx by id   ${jrxid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${itemName}
    Should Be Equal As Strings  ${resp.json()['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

    ${itemName2}=        FakerLibrary.name

    ${resp}=    Update Item Jrx   ${jrxid}  itemName=${itemName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${itemName2}
    Should Be Equal As Strings  ${resp.json()['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-2

    [Documentation]  Update Item Jrx item name updated - item name as empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Item Jrx   ${jrxid}  itemName=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-3

    [Documentation]  Update Item Jrx item name updated - description updated

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=     FakerLibrary.sentence

    ${resp}=    Update Item Jrx   ${jrxid}   description=${description2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${description2}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-4

    [Documentation]  Update Item Jrx item name updated - description as empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${description2}=     FakerLibrary.sentence

    ${resp}=    Update Item Jrx   ${jrxid}   description=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${empty}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}


JD-TC-UpdateItemJrx-5

    [Documentation]  Update Item Jrx item name updated - updated sku

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sku2}=     FakerLibrary.name

    ${resp}=    Update Item Jrx   ${jrxid}    sku=${sku2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${empty}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${sku2}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-6

    [Documentation]  Update Item Jrx item name updated - sku as empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sku2}=     FakerLibrary.name

    ${resp}=    Update Item Jrx   ${jrxid}    sku=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${empty}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${empty}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-7

    [Documentation]  Update Item Jrx item name updated - hsnCode as empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${sku2}=     FakerLibrary.name

    ${resp}=    Update Item Jrx   ${jrxid}    sku=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx by id   ${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()['itemName']}              ${empty}
    Should Be Equal As Strings  ${resp.json()['description']}           ${empty}
    Should Be Equal As Strings  ${resp.json()['sku']}                   ${empty}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()['hsnCode']['status']}     ${Toggle[0]}

JD-TC-UpdateItemJrx-UH1

    [Documentation]  Update Item Jrx item name updated - without 

    ${resp}=    Update Item Jrx   ${jrxid}    sku=${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
