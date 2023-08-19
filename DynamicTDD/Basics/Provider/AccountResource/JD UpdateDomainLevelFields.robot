*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        DomainVirtualField
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${subdomain_len}  0

*** Test Cases ***

JD-TC-UpdateDomainVirtualField-1
    [Documentation]   update domain virtual fields  of a valid provider
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    FOR  ${index}  IN RANGE  ${len}
        ${sublen}=  Get Length  ${domresp.json()[${index}]['subDomains']}
        ${subdomain_len}=  Evaluate  ${subdomain_len}+${sublen}
    END
    FOR   ${a}  IN RANGE   ${subdomain_len}
        ${resp}=  Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable   ${d}  ${resp.json()['sector']}
        ${fields}=   Get Domain level Fields  ${d}
        Log  ${fields.json()}
        Should Be Equal As Strings    ${fields.status_code}   200
        ${virtual_fields}=  get_Domainfields  ${fields.json()}
        Set Suite Variable  ${virtual_fields}
        ${resp}=  Update Domain_Level  ${virtual_fields}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${virtual_fields}=  json.dumps  ${virtual_fields}
        ${resp}=   Get Business Profile
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Test Variable  ${fields_businessprofile}  ${resp.json()['domainVirtualFields']}
        ${virtual_fields}=    evaluate    json.loads('''${virtual_fields}''')    json
        ${result}=  compare_json_data  ${virtual_fields}  ${fields_businessprofile}
        Log  ${result}
    END

JD-TC-UpdateSubDomainVirtualField-UH1
    [Documentation]  Update domain virtual fields without login
    ${resp}=  Update Domain_Level  ${virtual_fields}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}
    
JD-TC-UpdateSubDomainVirtualField-UH2
    [Documentation]   Update Sub-domain virtual fields  by  login as consumer
    ${resp}=    ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Domain_Level  ${virtual_fields}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateDomainVirtualField-2
    [Documentation]   update domain virtual fields  of a valid provider with another domain virtual fields
    ${resp}=  ProviderLogin  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${d}  ${resp.json()['sector']}
    ${resp}=  Update Domain_Level  ${virtual_fields}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_DOM_VIRTUAL_FIELDS}

