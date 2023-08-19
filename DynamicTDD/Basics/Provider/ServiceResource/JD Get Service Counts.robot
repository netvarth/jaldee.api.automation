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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${a}   0
${start}    150
@{service_duration}  10  20  30   40   50


*** Test Cases ***
 
 
JD-TC-GetServiceCount-1

    [Documentation]   Get Service Counts
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service       ${PUSERNAME111} 
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${description}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Get Service Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  1


JD-TC-GetServiceCount-2

    [Documentation]   Create more services and Get Service Counts
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${bool[1]}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${bool[1]}   ${bool[0]} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  3

JD-TC-GetServiceCount-3

    [Documentation]  Create a service ,Disable that service ,Then check the service counts
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int  min=200  max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=   Random Int  min=600  max=800
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}   ${Total}  ${bool[1]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${id}  ${resp.json()}  
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4
    ${resp}=  Disable service  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4
    ${resp}=  Enable service  ${id}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  4

JD-TC-GetServiceCount-UH2


    [Documentation]  Check the service counts without login
    ${resp}=  Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-GetServiceCount-UH3     

    [Documentation]  Check the service counts using consumer login
    ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Service Count
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


