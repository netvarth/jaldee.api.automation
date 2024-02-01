*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill Settings
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Keywords ***

Get Bill Settings

    Check And Create YNW Session
    ${resp}=    GET On Session    ynw  /provider/bill/settings/pos  expected_status=any
    [Return]  ${resp}

Enable Disable bill

    [Arguments]   ${status}

    Check And Create YNW Session
    ${resp}=    PUT On Session    ynw  /provider/bill/settings/${status}  expected_status=any
    [Return]  ${resp}


*** Test Cases ***

JD-TC-LoginDetails-1

    [Documentation]  Get Login Details for Indivial SP

    ${providers}=   Get File    /ebs/TDD/varfiles/providers.py
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

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${pkgId}=   Run Keyword And Continue On Failure  Set Variable  ${resp.json()['licensePkgID']}
        
        # ${resp}=  Get Business Profile
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${account_id}  ${resp.json()['id']}
        # Append To File  ${EXECDIR}/TDD/providers.txt  ${pro_num},${account_id}${\n}

        ${resp}=  Get Bill Settings 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    True

        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill Settings 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill Settings 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    True

        ${resp}=  Enable Disable bill  ${bool[0]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Bill Settings 
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        # ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # Log  '${resp.json()['serviceBillable']}'
    END


JD-TC-LoginDetails-2

    [Documentation]  Get Login Details for Multi-User Account

    ${providers}=   Get File    /ebs/TDD/varfiles/musers.py
    ${pro_list}=   Split to lines  ${providers}
    ${length}=  Get Length   ${pro_list}

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =
        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${lic_id}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        ${lic_name}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}
        ${domain}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['sector']}
        ${subdomain}=  Run Keyword And Continue On Failure  Set Variable  ${decrypted_data['subSector']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${pkgId}=   Run Keyword And Continue On Failure  Set Variable  ${resp.json()['licensePkgID']}

        
        # ${resp}=  Get Business Profile
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${account_id}  ${resp.json()['id']}
        # Append To File  ${EXECDIR}/TDD/providers.txt  ${pro_num},${account_id}${\n}

        # ${resp}=  Get Bill Settings 
        # Log   ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    True

        # ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        # Log   ${resp.content}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # Log  '${resp.json()['serviceBillable']}'
    END

    