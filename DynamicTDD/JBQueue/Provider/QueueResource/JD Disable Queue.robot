*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Queue
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Suite Setup     Run Keywords  clear_queue  ${PUSERNAME5}  AND  clear_location  ${PUSERNAME5}

*** Test Cases ***

JD-TC-Disable Queue-1
    [Documentation]  Disable  Queue of valid  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_location  ${PUSERNAME5}
    clear_service   ${PUSERNAME5}
    clear_queue  ${PUSERNAME5}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=DISABLED

JD-TC-Disable Queue-UH1
    [Documentation]  Disable Queue by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Disable Queue-UH2
    [Documentation]  Disable queue without login
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Disable Queue-UH3
    [Documentation]  Disable queue by another  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME214}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_queue  ${PUSERNAME214}
    ${resp}=  Get queues
    Log  ${resp.json()}
    ${resp}=  Disable Queue  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    
JD-TC-Disable Queue-UH4
    [Documentation]  Disable Queue using Invalid queue id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Disable Queue  0
    Should Be Equal As Strings  ${resp.status_code}  422   
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_NOT_FOUND}"
       
JD-TC-Disable Queue-UH5
    [Documentation]  Disable a already disabled queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=DISABLED
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  422  
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_ALREADY_DISABLED}"
       
    
    
