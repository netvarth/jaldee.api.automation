*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        SubDomainVirtualField
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
    
*** Variables ***
${invalid_domain}  invalid_domain
${subdomain_len}  0

*** Test Cases ***
JD-TC-UpdateSubDomainFields-1
    [Documentation]   update Sub-domain virtual fields  of a valid provider
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
        Set Suite Variable   ${sd}  ${resp.json()['subSector']}
        ${fields}=   Get subDomain level Fields  ${d}  ${sd}
        Log  ${fields.json()}
        Should Be Equal As Strings    ${fields.status_code}   200
        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
        Set Suite Variable  ${virtual_fields}
        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Business Profile
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Test Variable  ${fields_businessprofile}  ${resp.json()['subDomainVirtualFields'][0]['${sd}']}
        ${fields_businessprofile}=  json.dumps  ${fields_businessprofile} 
        ${virtual_fields}=  json.dumps  ${virtual_fields} 
        Should Be Equal As Strings  ${virtual_fields}  ${fields_businessprofile}
    END

JD-TC-UpdateSubDomainFields-UH1
    [Documentation]   update Sub-domain virtual fields  of a  provider with invalid sub sector
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${d}  ${resp.json()['sector']}
    Set Suite Variable   ${sd}  ${resp.json()['subSector']}
    ${fields}=   Get subDomain level Fields  ${d}  ${sd}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    Set Suite Variable  ${virtual_fields}
    ${resp}=  ProviderLogin  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_DOM_VIRTUAL_FIELDS}"
     
JD-TC-UpdateSubDomainFields-UH2
    [Documentation]   update Sub-domain virtual fields  of a  provider with invalid sub domain virtual fields
    ${resp}=  ProviderLogin  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${sd}  ${resp.json()['subSector']}
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"

JD-TC-UpdateSubDomainFields-UH3
    [Documentation]   update Sub-domain virtual fields  of a  provider with invalid sub sector
    ${resp}=  ProviderLogin  ${PUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${invalid_domain}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SUB_SECTOR}"

JD-TC-UpdateSubDomainFields-UH4
    [Documentation]  Update Sub-domain virtual fields without login
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}
    
JD-TC-UpdateSubDomainFields-UH5
    [Documentation]   Update Sub-domain virtual fields  by  login as consumer
    ${resp}=    ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

    
