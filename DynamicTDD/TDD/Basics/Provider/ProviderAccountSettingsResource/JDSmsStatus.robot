*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        jaldeeInegration
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-EnableDisableSmsStatus-1
    [Documentation]   Enabling SmsStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Sms Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Sms Status    ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    enableSms=${bool[1]}

JD-TC-EnableDisableSmsStatus-UH1
    [Documentation]  Enable SmsStatus without login

    ${resp}=  Sms Status     ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-EnableDisableSmsStatus-UH2
    [Documentation]  Enable already enabled SmsStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Sms Status     ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${SMS_SETTINGS_ALREDY_ENABLED}
JD-TC-EnableDisableSmsStatus-2
    [Documentation]   disabling SmsStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Sms Status    ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Account Settings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    enableSms=${bool[0]}

JD-TC-EnableDisableSmsStatus-UH3
    [Documentation]  Disable already Disabled SmsStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Sms Status     ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${SMS_SETTINGS_ALREDY_DISABLED}
