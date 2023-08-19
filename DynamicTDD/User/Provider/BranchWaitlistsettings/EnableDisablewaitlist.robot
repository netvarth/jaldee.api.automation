*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist Branch
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Test Cases ***

JD-TC-BranchEnableDisableWaitlist-1

    [Documentation]   Disable  waitlist by login as a  valid Branch
    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=True
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=False

JD-TC-BranchEnableDisableWaitlist-2

    [Documentation]  Enable waitlist by login as a  valid provider
    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=True


JD-TC-BranchEnableDisableWaitlist-UH1

    [Documentation]  Enable a waitlist when already enabled waitlist
    ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Waitlist
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_SETTINGS_ALREADY_ON}"

JD-TC-BranchEnableDisableWaitlist-UH2

    [Documentation]  Disable a waitlist when already disabled waitlist
    ${resp}=  Encrypted Provider Login  ${MUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${WAITLIST_SETTINGS_ALREADY_OFF}"


JD-TC-BranchEnableDisableWaitlist-UH3

    [Documentation]  Enable waitlist by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Enable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-BranchEnableDisableWaitlist-UH4

    [Documentation]  Disable waitlist by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Disable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-BranchEnableDisableWaitlist-UH5

    [Documentation]  Enable waitlist without login
     ${resp}=   Enable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


JD-TC-BranchEnableDisableWaitlist-UH6


    [Documentation]  Disable waitlist without login
     ${resp}=   Disable Waitlist
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


