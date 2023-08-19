*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Familymemeber
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
JD-TC-SmsCount-1
    [Documentation]   Get Account settings

    ${resp}=  ProviderLogin  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Get Business Profile
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get License UsageInfo
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${metric_length}=  Get Length  ${resp.json()['metricUsageInfo']}
    FOR    ${index}    IN RANGE    ${metric_length}
        IF    ${resp.json()['metricUsageInfo'][${index}]['metricId']} == 19
            ${remaining_sms_count}=  Set Variable    ${resp.json()['metricUsageInfo'][${index}]['dayTotalValue']}
            IF    ${remaining_sms_count}
               Exit For Loop
            END
        END
    END
    Log    ${remaining_sms_count}
    ${resp}=  Get Sms Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${remaining_sms_count}
                                                                                                                                                                                          