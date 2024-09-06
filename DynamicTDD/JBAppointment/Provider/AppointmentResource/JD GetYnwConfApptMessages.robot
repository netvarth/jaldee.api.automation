*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***

JD-TC-GetYnwConfAppointmentMessages-1

    [Documentation]  Get appointment messages from ynwconf.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get YnwConf Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

JD-TC-GetYnwConfAppointmentMessages-UH1

    [Documentation]  Get appointment messages from ynwconf by provider consumer login.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=  AddCustomer  ${CUSERNAME2}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME2}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME2}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME2}   ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get YnwConf Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetYnwConfAppointmentMessages-UH2

    [Documentation]  Get appointment messages from ynwconf without login.
    
    ${resp}=  Get YnwConf Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}      ${SESSION_EXPIRED}
    
