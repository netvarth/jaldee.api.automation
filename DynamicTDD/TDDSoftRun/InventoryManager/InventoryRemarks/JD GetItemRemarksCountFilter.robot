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

JD-TC-GetItemRemarksCountFilter-1

    [Documentation]   Get Item Remark  count Filter using account id. 


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME5}
    Set Suite Variable    ${accountId} 

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

    ${resp}=  Get Item Remark Filter   account-eq=${accountId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter   account-eq=${accountId}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-GetItemRemarksCountFilter-2

    [Documentation]   Get Item Remark count Filter using encid.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set suite Variable  ${remarks_encid2}  ${resp.json()}

    ${resp}=  Get Item Remark Filter   encId-eq=${remarks_encid2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter   encId-eq=${remarks_encid2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}


JD-TC-GetItemRemarksCountFilter-3

    [Documentation]   Get Item Remark count Filter using transaction enum.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark3}=    FakerLibrary.name
    Set Suite Variable  ${remark3}

    ${resp}=  Create Item Remarks   ${remark3}  ${transactionTypeEnum[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set suite Variable  ${remarks_encid3}  ${resp.json()}

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter   transactionTypeEnum-eq=${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}


JD-TC-GetItemRemarksCountFilter-4

    [Documentation]   Get Item Remark count Filter using id.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Item Remarks   ${remarks}  ${transactionTypeEnum[3]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${remarks_encid4}  ${resp.json()}

    ${resp}=  Get Item Remark   ${remarks_encid4}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}

    ${resp}=  Get Item Remark Filter   id-eq=${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter   id-eq=${id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}



JD-TC-GetItemRemarksCountFilter-5

    [Documentation]   update item remarks  and Get Item Remark  count filter using accountid.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${remark4}=    FakerLibrary.name
    Set Suite Variable  ${remark4}
    ${resp}=  Update Item Remark    ${remarks_encid1}   ${remark4}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter   account-eq=${accountId}     
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter   account-eq=${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-GetItemRemarksCountFilter-6

    [Documentation]    Get Item Remark count filter using transactionTypeEnum.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter  transactionTypeEnum-eq=${transactionTypeEnum[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

JD-TC-GetItemRemarksCountFilter-UH1

    [Documentation]    Get Item Remark count filter without login.

    ${resp}=  Get Item Remark Count Filter  transactionTypeEnum-eq=${transactionTypeEnum[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetItemRemarksCountFilter-UH2

    [Documentation]    Get Item Remark count filter using invalid data.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Count Filter   transactionTypeEnum-eq=${transactionTypeEnum[0]}   id-eq=${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    0
    
JD-TC-GetItemRemarksCountFilter-UH3

    [Documentation]    Get Item Remark count filter using EMPTY ID.


    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME5}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter      id-eq=${EMPTY}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${count}=  Get Length  ${resp.json()}

    ${resp}=  Get Item Remark Count Filter  id-eq=${EMPTY}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings   ${resp.json()}   ${count}

