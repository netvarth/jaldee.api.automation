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

JD-TC-GetConsentFormSettingsByAccount-1

    [Documentation]  Get Consent Form Settings by account

    ${resp}=  Encrypted Provider Login  ${PUSERNAME262}  ${PASSWORD}
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

    ${resp}=    Get Account Id   ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['isConsentFormEnabled']}'=='${bool[0]}'
        
        ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${qnr_name}=    FakerLibrary.name
    ${qnr_des}=     FakerLibrary.sentence
    ${qnr_ids}=     Create List  ${qnr_id}



    ${resp}=    Create Consent Form Settings  ${account_id}  ${qnr_name}  ${qnr_des}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-GetConsentFormSettingsByAccount-UH1

    [Documentation]  Get Consent Form Settings by account - where account id is invalid 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Get Consent Form Settings  ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-GetConsentFormSettingsByAccount-UH2

    [Documentation]  Get Consent Form Settings by account - without login 

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}
    
JD-TC-GetConsentFormSettingsByAccount-UH3

    [Documentation]  Get Consent Form Settings by account - with provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME262}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}

JD-TC-GetConsentFormSettingsByAccount-UH4

    [Documentation]  Get Consent Form Settings by account - where the account didnt created COnsent form settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME266}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id2}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   []