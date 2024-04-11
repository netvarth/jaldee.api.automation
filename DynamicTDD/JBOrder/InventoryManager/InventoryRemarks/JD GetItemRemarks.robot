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


*** Test Cases ***

JD-TC-GetItemRemarks-1

    [Documentation]  create item remarks with transaction type as adjustment and Get Item Remark. 


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

JD-TC-GetItemRemarks-2

    [Documentation]  create item remarks with transaction type as opening and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

JD-TC-GetItemRemarks-3

    [Documentation]  create item remarks with transaction type as PURCHASE_ORDER and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[2]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[2]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-4

    [Documentation]  create item remarks with transaction type as PURCHASE and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[3]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[3]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-5

    [Documentation]  create item remarks with transaction type as PURCHASE_RETURN and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[4]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[4]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-6

    [Documentation]  create item remarks with transaction type as SALES_ORDER and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[5]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-7

    [Documentation]  create item remarks with transaction type as SALES_ORDER_CANCEL and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[6]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[6]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-8

    [Documentation]  create item remarks with transaction type as SALES and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[7]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[7]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-9

    [Documentation]  create item remarks with transaction type as SALES_RETURN and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[8]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[8]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-10

    [Documentation]  create item remarks with transaction type as TRANSFER_IN and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[9]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[9]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}



JD-TC-GetItemRemarks-11

    [Documentation]  create item remarks with transaction type as TRANSFER_OUT and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[10]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[10]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-GetItemRemarks-12
    [Documentation]  create item remarks where remarks character as 500 and Get Item Remark.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${Text}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[6]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}



JD-TC-GetItemRemarks-UH1

    [Documentation]  Get Item Remark with invalid encid.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME3}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422


JD-TC-GetItemRemarks-UH2

    [Documentation]  Get Item Remark without login.


    ${resp}=  Get Item Remark   ${remarks}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetItemRemarks-UH3

    [Documentation]  Get Item Remark using SA login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Remark   ${remarks}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

