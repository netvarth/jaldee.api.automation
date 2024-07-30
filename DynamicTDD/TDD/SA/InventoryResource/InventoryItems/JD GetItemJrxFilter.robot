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

JD-TC-GetItemJrxFilter-1

    [Documentation]  Get Item Jrx Filter

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

    ${resp}=    Get Item Jrx Filter 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()[0]['itemName']}              ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()[0]['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['status']}     ${Toggle[0]}



JD-TC-GetItemJrxFilter-2

    [Documentation]  Get Item Jrx Filter - itemCode Filter

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx Filter   itemCode-eq=${jrxid}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()[0]['itemName']}              ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()[0]['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['status']}     ${Toggle[0]}

JD-TC-GetItemJrxFilter-3

    [Documentation]  Get Item Jrx Filter - itemName filter

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx Filter   itemName-eq=${itemName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()[0]['itemName']}              ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()[0]['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['status']}     ${Toggle[0]}


JD-TC-GetItemJrxFilter-4

    [Documentation]  Get Item Jrx Filter - itemCode Filter invalid item code

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     Random Int  min=999     max=9999

    ${resp}=    Get Item Jrx Filter    itemCode-eq=${inv}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       []

JD-TC-GetItemJrxFilter-5

    [Documentation]  Get Item Jrx Filter - hsnCode filter

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Item Jrx Filter   hsnCode-eq=${hsn_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemCode']}              ${jrxid}
    Should Be Equal As Strings  ${resp.json()[0]['itemName']}              ${itemName}
    Should Be Equal As Strings  ${resp.json()[0]['description']}           ${description}
    Should Be Equal As Strings  ${resp.json()[0]['sku']}                   ${sku}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['id']}         ${hsn_id}
    Should Be Equal As Strings  ${resp.json()[0]['hsnCode']['status']}     ${Toggle[0]}

JD-TC-GetItemJrxFilter-UH1

    [Documentation]  Get Item Jrx Filter - without login

    ${resp}=    Get Item Jrx Filter
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 


