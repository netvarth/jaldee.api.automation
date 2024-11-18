*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
${pro_var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/apre_providers.py
${hlpro_var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/hl_apre_providers.py
${US}           0
${hl_US}        0

*** Test Cases ***

Remove Files
   
    Remove File   ${pro_var_file}
    Create File   ${pro_var_file}

    Remove File   ${hlpro_var_file}
    Create File   ${hlpro_var_file}

JD-TC-SignupProviders
    [Documentation]  Signup a provider for every license, domain and subdomain.

    ${licresp}=   Get Licensable Packages
    Log  ${licresp.content}
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    
    ${busresp}=  Get BusinessDomainsConf
    Log  ${busresp.content}
    Should Be Equal As Strings  ${busresp.status_code}  200
    ${len}=  Get Length  ${busresp.json()}

    ${hl_licid}  ${hl_licname}=  get_highest_license_pkg

    FOR  ${licindex}  IN RANGE  ${liclen}
        Set Test Variable  ${licid}  ${licresp.json()[${licindex}]['pkgId']}
        Set Test Variable  ${licname}  ${licresp.json()[${licindex}]['displayName']}
        FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${dom}  ${busresp.json()[${dom_index}]['domain']}
            ${sublen}=  Get Length  ${busresp.json()[${dom_index}]['subDomains']}
            FOR  ${subindex}  IN RANGE  ${sublen}
                Set Test Variable  ${sdom}  ${busresp.json()[${dom_index}]['subDomains'][${subindex}]['subDomain']}

                ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=    Provider Signup  LicenseId=${licid}  Domain=${dom}  SubDomain=${sdom}
                Append To File  ${pro_var_file}  PUSERNAME${US}=${PUSERNAME_A}${\n}
                ${US} =  Evaluate  ${US}+1
                Set Global Variable  ${US}
                IF  '${licid}' == '${hl_licid}'
                    Append To File  ${hlpro_var_file}  HLPUSERNAME${hl_US}= ${PUSERNAME_A}${\n}
                    ${hl_US} =  Evaluate  ${hl_US}+1
                    Set Global Variable  ${hl_US}
                END
        
                ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
                Should Be Equal As Strings    ${resp.status_code}    200

                ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
                Log  ${resp.content}
                Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.status_code}  200

                ${resp}=  Get jaldeeIntegration Settings
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200
                Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
            END
        
        END
    END