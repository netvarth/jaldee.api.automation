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

JD-TC-UpdateItemRemarks-1

    [Documentation]  update item remarks with transaction type as opening . 


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${remarks_encid1}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid1}

    ${remark}=    FakerLibrary.first name

    ${resp}=  Update Item Remark    ${remarks_encid1}   ${remark}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remark}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid1}


JD-TC-UpdateItemRemarks-2

    [Documentation]  update item remarks with transaction type as ADJUSTMENT. 


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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

    ${resp}=  Update Item Remark    ${remarks_encid}   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}


JD-TC-UpdateItemRemarks-3

    [Documentation]  create item remarks with transaction type as PURCHASE_ORDER and update with same deatils.


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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[2]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

    ${resp}=  Update Item Remark    ${remarks_encid}   ${remarks}  ${transactionTypeEnum[2]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[2]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}



JD-TC-UpdateItemRemarks-4

    [Documentation]  update item remarks where remarks is different  transaction type as same.


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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[3]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

    ${remark}=    FakerLibrary.first name

    ${resp}=  Update Item Remark    ${remarks_encid}   ${remark}  ${transactionTypeEnum[3]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remark}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[3]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}




JD-TC-UpdateItemRemarks-5

    [Documentation]  update item remarks with transaction type as SALES_ORDER and Get Item Remark.


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
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[4]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}

    ${resp}=  Update Item Remark    ${remarks_encid}   ${remarks}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[5]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}





JD-TC-UpdateItemRemarks-UH1

    [Documentation]  Update Item Remarks with invalid encid


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Remark    ${remarks}   ${remarks}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_REMARK_CODE}



JD-TC-UpdateItemRemarks-UH2

    [Documentation]  Update Item Remarks without login.

    ${resp}=  Update Item Remark    ${remarks_encid1}   ${EMPTY}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateItemRemarks-UH3

    [Documentation]  Get Item Remark using SA login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Item Remark    ${remarks_encid1}   ${EMPTY}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateItemRemarks-UH4

    [Documentation]    Update Item Remarks with empty remarks


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Remark    ${remarks_encid1}   ${EMPTY}  ${transactionTypeEnum[5]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_REMARK_NAME}


