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
JD-TC-Update Today Appointment Settings -1
    [Documentation]   Update Appointment settings with Today status is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME187}
    Set Suite Variable    ${pid}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[1]}

    ${resp}=   Disable Today Appointment
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

JD-TC-Update Today Appointment Settings -2
    [Documentation]   Update Appointment settings with Today status is Enable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME188}
    Set Suite Variable    ${pid}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[1]}

    ${resp}=   Disable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Enable Today Appointment
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

JD-TC-Update Today Appointment Settings -UH1
    [Documentation]   Update Appointment settings trying to Today status is Enable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME188}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME188}
    Set Suite Variable    ${pid}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[1]}

    ${resp}=   Enable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${TODAY_APPT_ALREADY_ON}"

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Today Appointment Settings -UH2
    [Documentation]   Update Appointment settings trying to Today status is Disable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME187}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=   get_acc_id  ${PUSERNAME187}
    Set Suite Variable    ${pid}   

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}   ${bool[1]}

    ${resp}=   Disable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${TODAY_APPT_ALREADY_OFF}"    

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}                   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['futureAppt']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['account']['id']}                 ${pid}
    Should Be Equal As Strings  ${resp.json()['account']['accountType']}        ${accountType}

JD-TC-Update Today Appointment Settings-UH3
    [Documentation]   Update Appointment settings by Disable Today appmt without provider login 
    ${resp}=   Disable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Update Today Appointment Settings-UH4
    [Documentation]   Update Appointment settings by Enable Today appmt without provider login 
    ${resp}=   Enable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Update Today Appointment Settings-UH5
    [Documentation]   Update Appointment settings by Disable Today Appmt with Consumer Login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Update Today Appointment Settings-UH6
    [Documentation]   Update Appointment settings by Enable Today Appmt with Consumer Login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Today Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"