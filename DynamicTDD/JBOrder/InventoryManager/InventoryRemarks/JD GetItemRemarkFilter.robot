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

JD-TC-GetItemRemarksFilter-1

    [Documentation]   Get Item Remark Filter using account id. 


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLMUSERNAME4}
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
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remarks}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid1}

JD-TC-GetItemRemarksFilter-2

    [Documentation]   Get Item Remark Filter using encid.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark1}=    FakerLibrary.name
    Set Suite Variable  ${remark1}
    ${resp}=  Create Item Remarks   ${remark1}  ${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set suite Variable  ${remarks_encid2}  ${resp.json()}

    ${resp}=  Get Item Remark Filter   encId-eq=${remarks_encid2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark1}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid2}


JD-TC-GetItemRemarksFilter-3

    [Documentation]   Get Item Remark Filter using transaction enum.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark2}=    FakerLibrary.name
    Set Suite Variable  ${remark2}

    ${resp}=  Create Item Remarks   ${remark2}  ${transactionTypeEnum[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set suite Variable  ${remarks_encid3}  ${resp.json()}

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[1]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid3}



JD-TC-GetItemRemarksFilter-4

    [Documentation]   Get Item Remark Filter using id.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remark3}=    FakerLibrary.name
    Set Suite Variable  ${remark3}
    ${resp}=  Create Item Remarks   ${remark3}  ${transactionTypeEnum[3]}   
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
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark3}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[3]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid4}



JD-TC-GetItemRemarksFilter-5

    [Documentation]   update item remarks  and Get Item Remark filter using accountid.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
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
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark3}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[3]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid4}
    Should Be Equal As Strings    ${resp.json()[1]['remark']}    ${remark2}
    Should Be Equal As Strings    ${resp.json()[1]['transactionTypeEnum']}    ${transactionTypeEnum[1]}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${remarks_encid3}
    Should Be Equal As Strings    ${resp.json()[2]['remark']}    ${remark1}
    Should Be Equal As Strings    ${resp.json()[2]['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()[2]['encId']}    ${remarks_encid2}
    Should Be Equal As Strings    ${resp.json()[3]['remark']}    ${remark4}
    Should Be Equal As Strings    ${resp.json()[3]['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()[3]['encId']}    ${remarks_encid1}

JD-TC-GetItemRemarksFilter-6

    [Documentation]    Get Item Remark filter using transactionTypeEnum.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['remark']}    ${remark1}
    Should Be Equal As Strings    ${resp.json()[0]['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()[0]['encId']}    ${remarks_encid2}
    Should Be Equal As Strings    ${resp.json()[1]['remark']}    ${remark4}
    Should Be Equal As Strings    ${resp.json()[1]['transactionTypeEnum']}    ${transactionTypeEnum[0]}
    Should Be Equal As Strings    ${resp.json()[1]['encId']}    ${remarks_encid1}

JD-TC-GetItemRemarksFilter-UH1

    [Documentation]    Get Item Remark filter without login.

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[0]}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetItemRemarksFilter-UH2

    [Documentation]    Get Item Remark filter using invalid data.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter   transactionTypeEnum-eq=${transactionTypeEnum[0]}   id-eq=${id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []
    
JD-TC-GetItemRemarksFilter-UH3

    [Documentation]    Get Item Remark filter using EMPTY ID.


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Remark Filter      id-eq=${EMPTY}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

