*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/KeywordNameLogger.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Keywords ***
Check Deprication
    [Arguments]    ${response}  ${keyword_name}
    IF  'Deprecated-Url' in &{response.headers}
        Log  ${response.headers['Deprecated-Url']}
        Log  *${keyword_name} DEPRECATED in REST.*  level=WARN
    END

Get BusinessDomainsConf
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /ynwConf/businessDomains   expected_status=any
    # IF  'Deprecated-Url' in &{resp.headers}
    #     Log  ${resp.headers['Deprecated-Url']}
    #     Log  *Get BusinessDomainsConf DEPRECATED in REST.*  level=WARN
    # END
    Check Deprication  ${resp}  Get BusinessDomainsConf
    RETURN  ${resp}




*** Test Cases ***
Testing Deprecation
    
    # example_keyword
    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.headers}
    # Log  ${resp.headers['Deprecated-Url']}
    # IF  'Deprecated-Url' in &{resp.headers}
    #     Log  ${resp.headers['Deprecated-Url']}
    # END

*** COMMENTS ***
JD-TC-55num-1
    ${PUSERPH0}=    Generate Random 555 Number
    Log To Console  ${PUSERPH0}

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  Random Int  min=${0}   max=${dom_len-1}    
    Set Suite Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}

    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    ${sdom}=  Random Int  min=${0}  max=${sdom_len-1}
    Set Suite Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
    Log   ${subdomain}