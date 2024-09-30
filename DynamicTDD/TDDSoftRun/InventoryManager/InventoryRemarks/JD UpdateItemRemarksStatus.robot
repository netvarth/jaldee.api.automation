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
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${invalidNum}        1245
${invalidEma}        asd122



*** Test Cases ***

JD-TC-UpdateItemRemarkStatus-1

    [Documentation]  create reamrks and update status as inactive . 


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()['status']}     ${status[0]}

    ${resp}=  Update Item Remark Status     ${status[1]}   ${remarks_encid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${resp}=  Get Item Remark   ${remarks_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid1}
    Should Be Equal As Strings    ${resp.json()['status']}     ${status[1]}


JD-TC-UpdateItemRemarkStatus-2

    [Documentation]  update item remarks with transaction type as ADJUSTMENT then change status as inactive. 


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${remark}=    FakerLibrary.first name

    ${resp}=  Create Item Remarks   ${remark}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${remarks_encid}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remark}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}
   Should Be Equal As Strings    ${resp.json()['status']}     ${status[0]}


    ${remark2}=    FakerLibrary.first name
    Set Suite Variable  ${remark2}
    ${resp}=  Update Item Remark    ${remarks_encid}   ${remark2}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}
   Should Be Equal As Strings    ${resp.json()['status']}     ${status[0]}

    ${resp}=  Update Item Remark Status     ${status[1]}   ${remarks_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark   ${remarks_encid}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()['encId']}    ${remarks_encid}
   Should Be Equal As Strings    ${resp.json()['status']}     ${status[1]}

    ${resp}=  Get Item Remark Filter      status-eq=${status[1]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid}
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${status[1]}



JD-TC-UpdateItemRemarkStatus-3

    [Documentation]  try to update remarks thats in inactive status .then active the status.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark1}=    FakerLibrary.first name

    ${resp}=  Update Item Remark    ${remarks_encid}   ${remarks}  ${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Update Item Remark Status      ${status[0]}   ${remarks_encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter      status-eq=${status[0]}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid}
    Should Be Equal As Strings    ${resp.json()[0]['status']}     ${status[0]}

JD-TC-UpdateItemRemarkStatus-UH1

    [Documentation]  Try to Update already active status remarks to active status.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Update Item Remark Status     ${status[0]}   ${remarks_encid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${STATUS_ALREADY_UPDATED}

JD-TC-UpdateItemRemarkStatus-UH2

    [Documentation]  Try to Update already inactive status remarks to inactive.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Remark Status    ${status[1]}    ${remarks_encid1} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${STATUS_ALREADY_UPDATED}



JD-TC-UpdateItemRemarkStatus-UH3

    [Documentation]  Update Item Remarks status with invalid encid


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Remark Status      ${status[0]}   ${remarks}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_REMARK_CODE}



JD-TC-UpdateItemRemarkStatus-UH4

    [Documentation]  Update Item Remarks status without login.

    ${resp}=  Update Item Remark Status      ${status[0]}   ${remarks_encid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateItemRemarkStatus-UH5

    [Documentation]  Update Item Remarks status using SA login.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Update Item Remark Status    ${status[0]}    ${remarks_encid} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}




