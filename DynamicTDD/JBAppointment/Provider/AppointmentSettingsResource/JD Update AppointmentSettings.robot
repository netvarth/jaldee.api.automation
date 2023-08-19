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
${accountType}      INDEPENDENT_SP

*** Test Cases ***
JD-TC-Update Appointment Settings-1
    [Documentation]   Update Appointment settings with enableToday and futureAppt are Disable
    
    ${resp}=  Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME167}
    Set Suite Variable    ${pid}

    clear_service   ${PUSERNAME167}
    clear_location  ${PUSERNAME167}    

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
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

    ${resp}=    Update Appointmet Settings   ${bool[0]}   ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Appointment Settings-2
    [Documentation]   Update Appointment settings with enableToday is Enable
    ${resp}=  Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Update Appointmet Settings   ${bool[1]}   ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Appointment Settings-3
    [Documentation]   Update Appointment settings with futureAppt is Enable
    ${resp}=  Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Update Appointmet Settings   ${bool[0]}   ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Appointment Settings-4
    [Documentation]   Update Appointment settings with with enableToday and futureAppt are Enable
    ${resp}=  Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Update Appointmet Settings   ${bool[1]}   ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Appointment Settings-UH1
    [Documentation]   Update Appointment settings by without login provider
    ${resp}=    Update Appointmet Settings   ${bool[1]}   ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Update Appointment Settings-UH2
    [Documentation]   Update Appointment settings by Consumer Login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Update Appointmet Settings   ${bool[1]}   ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"