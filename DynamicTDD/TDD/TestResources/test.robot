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
Deprecated Keyword 1
    [Documentation]  *DEPRECATED in rest.*
    Log  This is a deprecated keyword.


Deprecated Keyword 2
    Log  This is a deprecated keyword.
    [Documentation]  *DEPRECATED in rest.*

Deprecated Keyword 3
    Log  This is a deprecated keyword.
    comment  *DEPRECATED in rest.*

Deprecated Keyword 4
    Log  This is a deprecated keyword.
    Log  Some other action here
    IF  'Deprecated-Url'=='Deprecated-Url'
        # Log  *DEPRECATED in rest.*  level=WARN  repr=DEPRECATED 
        Log  *DEPRECATED in rest.*  level=WARN  
    END

Get BusinessDomainsConf
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /ynwConf/businessDomains   expected_status=any
    IF  'Deprecated-Url' in &{resp.headers}
        Log  ${resp.headers['Deprecated-Url']}
        Log  *Get BusinessDomainsConf DEPRECATED in REST.*  level=WARN
    END
    RETURN  ${resp}




*** Test Cases ***
Testing Deprecation
    # Deprecated Keyword 1
    # Deprecated Keyword 2
    # Deprecated Keyword 3
    Deprecated Keyword 4
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