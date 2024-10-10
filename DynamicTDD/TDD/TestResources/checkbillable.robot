*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        ConsumerLogin
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot


*** Variables ***

# ${pro_var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/apre_providers.py
${pro_var_file}     ${EXECDIR}/TDD/varfiles/providers.py
&{nonbillable}

*** Test Cases ***

JD-TC-check billable

    [Documentation]     check all domains and subdomains are billable

    
    ${providers}=   Get File    ${pro_var_file}
    ${pro_list}=   Split to lines  ${providers}
    ${length}=  Get Length   ${pro_list}

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =

        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${lic_id}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${lic_name}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
        ${domain}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['sector']}
        ${subdomain}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['subSector']}

        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp2.status_code}    200
        # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp2.json()['serviceBillable']}   True
        IF  '${resp2.json()['serviceBillable']}' == '${bool[0]}'
            Set To Dictionary 	${nonbillable} 	${domain}=${subdomain}
        END
    
    END

    Log  ${nonbillable}