*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${a}   0
${start}   1
*** Test Cases ***

JD-RedisCache-1

    [Documentation]  Remove Redis Chache
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${cup_code}=   FakerLibrary.word
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${length}=  Evaluate   ${length}-1  
    FOR   ${a}  IN RANGE  ${start}   ${length}
        Log   ${PUSERNAME${a}}
        ${User} =   Set Variable   ${PUSERNAME${a}}  
        ${accid}=   get_acc_id   ${User}
        ${resp}=  Remove Redis Cache    ${accid}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Get Redis Cache  ${accid}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings   ${resp.json()}  False
        Log  ${resp.json()}
    END    

JD-RedisCache-UH1

    [Documentation]  Remove Redis Cache without SuperAdmin Login
    ${accid}=   get_acc_id   ${PUSERNAME45}
    ${resp}=  Remove Redis Cache    ${accid}
    Should Be Equal As Strings    ${resp.status_code}    419
    Log   ${resp.json()}
    Should Be Equal As Strings  "${resp.json()}"  "${SA_SESSION_EXPIRED}" 

JD-RedisCache-UH2
 
    [Documentation]  Remove Redis Cache with invalid  account id
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200       
    ${resp}=  Remove Redis Cache    0000
    Should Be Equal As Strings    ${resp.status_code}    422
