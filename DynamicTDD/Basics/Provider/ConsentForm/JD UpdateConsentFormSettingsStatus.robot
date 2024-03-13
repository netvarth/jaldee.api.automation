*** Settings ***

Suite Teardown    Run Keywords  Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Consent FOrm
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

JD-TC-UpdateConsentFormSettingsStatus-1

    [Documentation]  Update Consent Form Settings Status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qnr_id}  ${resp.json()[0]['id']}

    ${resp1}=  Run Keyword If   '${resp.json()[0]['status']}' == '${status[1]}'  Superadmin Change Questionnaire Status  ${qnr_id}  ${status[0]}  ${account_id}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qnr_name}=    FakerLibrary.name
    ${qnr_des}=     FakerLibrary.sentence
    ${qnr_ids}=     Create List  ${qnr_id}
    Set Suite Variable      ${qnr_ids}

    ${resp}=  SuperAdmin Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableConsentForm']}'=='${bool[0]}'

        ${resp}=    Enable Disable Provider Consent Form   ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableConsentForm']}     ${bool[1]}

    ${qnr_name}=    FakerLibrary.name
    Set Suite Variable  ${qnr_name}
    ${qnr_des}=     FakerLibrary.sentence
    Set Suite Variable  ${qnr_des}
    ${qnr_ids}=     Create List  ${qnr_id}
    Set Suite Variable   ${qnr_ids}

    ${resp}=    Create Provider Consent Form Settings  ${qnr_name}  ${qnr_des}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${toggle[0]}

    IF  '${resp.json()[0]['status']}'=='${toggle[0]}'

        ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}
    Should Be Equal As Strings  ${resp.json()[0]['status']}         ${toggle[1]}


JD-TC-UpdateConsentFormSettingsStatus-UH1

    [Documentation]  Update Consent Form Settings Status - changing status enable to enable  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-UpdateConsentFormSettingsStatus-UH2

    [Documentation]  Update Consent Form Settings Status - changing status enable to disable  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateConsentFormSettingsStatus-UH3

    [Documentation]  Update Consent Form Settings Status - changing status disable to disable  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-UpdateConsentFormSettingsStatus-UH4

    [Documentation]  Update Consent Form Settings Status - without login  

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}

JD-TC-UpdateConsentFormSettingsStatus-UH5

    [Documentation]  Update Consent Form Settings Status - with SA login  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-UpdateConsentFormSettingsStatus-UH7

    [Documentation]  Update Consent Form Settings Status - ConsentForm id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME274}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=11111  max=99999

    ${resp}=    Update Provider Consent Form Settings Status  ${inv}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_CONSENT_FORM_ID}

JD-TC-UpdateConsentFormSettingsStatus-UH5

    [Documentation]  Update Consent Form Settings Status - with Consumer login  

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Provider Consent Form Settings Status  ${cfid}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}