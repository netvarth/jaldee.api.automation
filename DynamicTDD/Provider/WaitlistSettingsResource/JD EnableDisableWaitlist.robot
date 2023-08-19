*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Provider Waitlist 
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-EnableDisableWaitlist-1
    [Documentation]  Disable  waitlist by login as a  valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  enabledWaitlist=${bool[0]}

JD-TC-EnableDisableWaitlist-2
    [Documentation]  Enable waitlist by login as a  valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[0]}
    ${resp}=   Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  View Waitlist Settings
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}

JD-TC-EnableDisableWaitlist-UH1
    [Documentation]  Enable a waitlist when already enabled waitlist
    ${resp}=  ProviderLogin  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_SETTINGS_ALREADY_ON}"

JD-TC-EnableDisableWaitlist-UH2
    [Documentation]  Disable a waitlist when already disabled waitlist
    ${resp}=  ProviderLogin  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_SETTINGS_ALREADY_OFF}"

JD-TC-EnableDisableWaitlist-UH3
     [Documentation]  Enable waitlist by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Enable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableWaitlist-UH4      
     [Documentation]  Disable waitlist by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Disable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-EnableDisableWaitlist-UH5
     [Documentation]  Enable waitlist without login
     ${resp}=   Enable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
     
JD-TC-EnableDisableWaitlist-UH6
     [Documentation]  Disable waitlist without login
     ${resp}=   Disable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}" 
     
JD-TC-EnableDisableWaitlist-PRE
    [Documentation]  Enable waitlist by login as a  valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   02s
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}
