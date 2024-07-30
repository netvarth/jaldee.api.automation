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

JD-TC-UpdateConsentFormSettings-1

    [Documentation]  Update Consent Form Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME264}  ${PASSWORD}
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

    ${resp}=    Enable Disable Consent Form   ${account_id}  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qnr_name}=    FakerLibrary.name
    ${qnr_des}=     FakerLibrary.sentence
    ${qnr_ids}=     Create List  ${qnr_id}
    Set Suite Variable      ${qnr_ids}

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

    ${qnr_name2}=    FakerLibrary.name
    Set Suite Variable  ${qnr_name2}
    ${qnr_des2}=     FakerLibrary.sentence
    Set Suite Variable  ${qnr_des2}

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-2

    [Documentation]  Update Consent Form Settings - where qnr id is empty list

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list}=    Create List

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${list}


JD-TC-UpdateConsentFormSettings-3

    [Documentation]  Update Consent Form Settings - qnr description is empty 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${empty}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${empty}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-4

    [Documentation]  Update Consent Form Settings - qnr name is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${empty}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${empty}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-5

    [Documentation]  Update Consent Form Settings - consent form id is empty

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Consent Form Settings  ${account_id}  ${empty}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_CONSENT_FORM_ID}


JD-TC-UpdateConsentFormSettings-6

    [Documentation]  Update Consent Form Settings - account id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=    Update Consent Form Settings  ${fake}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-UpdateConsentFormSettings-7

    [Documentation]  Update Consent Form Settings - consent form id is invalid

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=    Update Consent Form Settings  ${account_id}  ${fake}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_CONSENT_FORM_ID}

JD-TC-UpdateConsentFormSettings-8

    [Documentation]  Update Consent Form Settings - qnr name is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qname}=    FakerLibrary.name

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qname}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qname}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-9

    [Documentation]  Update Consent Form Settings - qnr description is changed

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${qdes}=     FakerLibrary.sentence

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${qdes}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consent Form Settings  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qdes}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-10

    [Documentation]  Update Consent Form Settings - without login

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-UpdateConsentFormSettings-11

    [Documentation]  Update Consent Form Settings - with provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME264}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Consent Form Settings  ${account_id}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-UpdateConsentFormSettings-12

    [Documentation]  Update Consent Form Settings - update using another provider account id who dont have an Consent form settings

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

    ${resp}=    Update Consent Form Settings  ${account_id2}  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422