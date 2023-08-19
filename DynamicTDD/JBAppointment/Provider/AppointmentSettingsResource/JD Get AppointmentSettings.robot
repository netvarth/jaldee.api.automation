*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Appointment, Schedule
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}         manicure 
${SERVICE2}         pedicure
${self}             0
${accountType}      INDEPENDENT_SP

*** Test Cases ***
JD-TC-Get Appointment Settings-1
    [Documentation]   Get Appointment settings by the Proivder
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME155}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME155}

    clear_service   ${PUSERNAME155}
    clear_location  ${PUSERNAME155}    

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}  
    Should Be Equal As Strings  ${resp.json()['consumerApp']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['consumerApp']}                   ${bool[0]}  

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Get Appointment Settings-UH1
    [Documentation]   Get Appointment settings by without login provider

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

       
JD-TC-Get Appointment Settings-UH2
    [Documentation]   Get Appointment settings by Consumer Login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"