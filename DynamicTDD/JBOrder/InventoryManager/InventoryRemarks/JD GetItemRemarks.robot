*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
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
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122

*** Keywords ***
Create Item Remarks

    [Arguments]  ${remark}   ${transactionTypeEnum}  
    ${data}=  Create Dictionary  remark=${remark}   transactionTypeEnum=${transactionTypeEnum}    
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/inventory/remark   data=${data}  expected_status=any
    RETURN  ${resp} 

Get Item Remark
    [Arguments]   ${id}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/remark/${id}   expected_status=any
    RETURN  ${resp} 

Update Item Remark
    [Arguments]  ${encId}  ${remark}   ${transactionTypeEnum}  
    ${data}=  Create Dictionary    encId=${encId}   remark=${remark}   transactionTypeEnum=${transactionTypeEnum}    
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/inventory/remark   data=${data}  expected_status=any
    RETURN  ${resp} 

Get Item Remark Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw /provider/inventory/remark  params=${param}  expected_status=any
    RETURN  ${resp}

Get Item Remark Count Filter
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw /provider/inventory/remark  params=${param}  expected_status=any
    RETURN  ${resp}

Get Inventoryitem
    [Arguments]   ${id}     
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/inventory/inventoryitem/invcatalog/${id}   expected_status=any
    RETURN  ${resp} 

*** Test Cases ***

JD-TC-GetItemRemarks-1

    [Documentation]  create item remarks with transaction type as adjustment.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}

JD-TC-GetItemRemarks-2

    [Documentation]  create item remarks with transaction type as opening.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[0]}

JD-TC-GetItemRemarks-3

    [Documentation]  create item remarks with transaction type as PURCHASE_ORDER.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[2]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[2]}


JD-TC-GetItemRemarks-4

    [Documentation]  create item remarks with transaction type as PURCHASE.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[3]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[3]}


JD-TC-GetItemRemarks-5

    [Documentation]  create item remarks with transaction type as PURCHASE_RETURN.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[4]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[4]}


JD-TC-GetItemRemarks-6

    [Documentation]  create item remarks with transaction type as SALES_ORDER.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[5]}


JD-TC-GetItemRemarks-7

    [Documentation]  create item remarks with transaction type as SALES_ORDER_CANCEL.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[6]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[6]}


JD-TC-GetItemRemarks-8

    [Documentation]  create item remarks with transaction type as SALES.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[7]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[7]}


JD-TC-GetItemRemarks-9

    [Documentation]  create item remarks with transaction type as SALES_RETURN.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[8]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[8]}


JD-TC-GetItemRemarks-10

    [Documentation]  create item remarks with transaction type as TRANSFER_IN.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[9]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[9]}



JD-TC-GetItemRemarks-11

    [Documentation]  create item remarks with transaction type as TRANSFER_OUT.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[10]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[10]}


JD-TC-GetItemRemarks-12
    [Documentation]  create item remarks where remarks character as 500.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${Text}=  Generate Random String  256
    ${resp}=  Create Item Remarks   ${Text}  ${transactionTypeEnum[6]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remarks']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[6]}



JD-TC-GetItemRemarks-UH1

    [Documentation]  create item remarks with empty remarks.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${EMPTY}  ${transactionTypeEnum[10]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-GetItemRemarks-UH2

    [Documentation]  create item remarks without login.


    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[10]}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetItemRemarks-UH3

    [Documentation]  create item remarks using SA login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[10]}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

