***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Future Checkin
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


JD-TC-EnableDisableFutureCheckin-1
    [Documentation]  Disable future checkin by login as a  valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=False

JD-TC-EnableDisableFutureCheckin-2
    [Documentation]  Enable future checkin by login as a  valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Future Checkin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  futureDateWaitlist=True


JD-TC-EnableDisableFutureCheckin-UH1      
     [Documentation]  Enable future checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Enable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableFutureCheckin-UH2      
     [Documentation]  Disable future checkin by login as a consumer
     ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=   Disable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
     
JD-TC-EnableDisableFutureCheckin-UH3
     [Documentation]  Enable future checkin without login
     ${resp}=   Enable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-EnableDisableFutureCheckin-UH4
     [Documentation]  Disable futurecheckin without login
     ${resp}=   Disable Future Checkin
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-EnableDisableFutureCheckin-UH5
    [Documentation]  Disable a already disabled future checkin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Future Checkin
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_ALREADY_OFF}"
     
JD-TC-EnableDisableFutureCheckin-UH6
    [Documentation]  Enable a already enabled future checkin
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Enable Future Checkin
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_ALREADY_ON}"





