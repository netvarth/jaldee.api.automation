*** Settings ***

Suite Teardown    Run Keywords  Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Consent Form
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/excelfuncs.py


*** Variables ***
${xlFile}    ${EXECDIR}/TDD/ConsentForm.xlsx

*** Test Cases ***

JD-TC-Enable Disable Consent Form-1
    [Documentation]  Enable Disable Consent Form

    ${resp}=  Encrypted Provider Login  ${PUSERNAME261}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Account Id   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isConsentFormEnabled']}  ${bool[0]}
    
    IF  '${resp.json()['isConsentFormEnabled']}'=='${bool[0]}'
        
        ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Account Id   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['isConsentFormEnabled']}  ${bool[1]}

JD-TC-Enable Disable Consent Form-UH1
    
    [Documentation]  Enable Disable Consent Form -  which is already enabled  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ALREDY_ENABLED}=  format String   ${ALREDY_ENABLED}   Consent Form

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${ALREDY_ENABLED}

JD-TC-Enable Disable Consent Form-UH2
    
    [Documentation]  Enable Disable Consent Form -  disable consent form which is already disabled

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CDL_ALREDY_DISABLED}=  format String   ${CDL_ALREDY_DISABLED}   Consent Form

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${CDL_ALREDY_DISABLED}

JD-TC-Enable Disable Consent Form-UH3
    
    [Documentation]  Enable Disable Consent Form -  without login

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}

JD-TC-Enable Disable Consent Form-UH4
    
    [Documentation]  Enable Disable Consent Form -  using provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME261}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}

JD-TC-Enable Disable Consent Form-UH5
    
    [Documentation]  Enable Disable Consent Form -  where account id is Invalid 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     Random Int  min=1000000   max=9999999

    ${resp}=    Enable Disable Consent Form   ${inv}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422