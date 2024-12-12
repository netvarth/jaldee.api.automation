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
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}  SERVICE1
@{service_duration}  10  20  30   40   50


*** Test Cases ***

JD-TC-Enable Service-1

        [Documentation]  Enable a service by provider login
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        ${resp}=  Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        # clear_service       ${PUSERNAME90}
        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${account_id}  ${resp.json()['id']}
        ${resp}=  Create Service   ${SERVICE1}   ${description}   ${service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
        Log  ${resp}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${id}  ${resp.json()}
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}    notificationType=${notifytype[2]}  status=${status[0]}  bType=${btype} 
        ${resp}=  Disable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  status=${status[1]}  bType=${btype}          
        ${resp}=  Enable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  status=${status[0]}  bType=${btype}  
        
JD-TC-Enable Service-UH1

        [Documentation]  Enable Service of another provider
        ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Enable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Enable Service-UH2

        [Documentation]  Enable  Invalid service id
        ${resp}=  Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Enable service  0  
        Should Be Equal As Strings  ${resp.status_code}  404
        Should Be Equal As Strings  "${resp.json()}"  "${NO_SUCH_SERVICE}"

JD-TC-Enable Service-UH3

        [Documentation]   Enable  a already enabled service
        ${resp}=  Encrypted Provider Login  ${PUSERNAME90}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Enable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_ALREADY_ACTIVE}"

JD-TC-Enable Service-UH4

        [Documentation]  Enable a service without login
        ${resp}=  Enable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-EnableService-UH5

        [Documentation]  Enable a service using consumer login
        # ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${CUSERNAME8}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME8}

        ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Enable service  ${id}  
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}