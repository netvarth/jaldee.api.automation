*** Settings ***

Suite Teardown    Run Keywords  Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Consent Form
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
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

JD-TC-UpdateConsentForm-1

    [Documentation]   Update Consent Form

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
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

    ${qnr_name2}=    FakerLibrary.name
    Set Suite Variable  ${qnr_name2}
    ${qnr_des2}=     FakerLibrary.sentence
    Set Suite Variable  ${qnr_des2}

    ${resp}=    Create Provider Consent Form Settings  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

    Set Suite Variable          ${cfid2}     ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[1]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[1]['qnrIds']}         ${qnr_ids}

    ${resp}=    Get Provider Consent Form Settings By Id    ${cfid2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()['qnrIds']}         ${qnr_ids}

    ${qnr_name3}=    FakerLibrary.name
    Set Suite Variable  ${qnr_name3}
    ${qnr_des3}=     FakerLibrary.sentence
    Set Suite Variable  ${qnr_des3}

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name3}  ${qnr_des3}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name3}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des3}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

    Set Suite Variable          ${cfid2}     ${resp.json()[1]['id']}
    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[1]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[1]['qnrIds']}         ${qnr_ids}


JD-TC-UpdateConsentFormSettings-2

    [Documentation]  Update Consent Form Settings - where qnr id is empty list

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=    Create List

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${list}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${list}


JD-TC-UpdateConsentFormSettings-3

    [Documentation]  Update Consent Form Settings - qnr description is empty 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${empty}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${empty}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-4

    [Documentation]  Update Consent Form Settings - qnr name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${empty}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${empty}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-5

    [Documentation]  Update Consent Form Settings - consent form id is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings  ${empty}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_CONSENT_FORM_ID}


JD-TC-UpdateConsentFormSettings-7

    [Documentation]  Update Consent Form Settings - consent form id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=    Update Provider Consent Form Settings  ${fake}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INV_CONSENT_FORM_ID}

JD-TC-UpdateConsentFormSettings-8

    [Documentation]  Update Consent Form Settings - qnr name is changed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qname}=    FakerLibrary.name

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qname}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qname}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-9

    [Documentation]  Update Consent Form Settings - qnr description is changed

    ${resp}=  Encrypted Provider Login  ${PUSERNAME270}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${qdes}=     FakerLibrary.sentence

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qdes}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[0]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${qdes}
    Should Be Equal As Strings  ${resp.json()[0]['qnrIds']}         ${qnr_ids}

JD-TC-UpdateConsentFormSettings-10

    [Documentation]  Update Consent Form Settings - without login

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}


JD-TC-UpdateConsentFormSettings-11

    [Documentation]  Update Consent Form Settings - with sa login

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}


JD-TC-UpdateConsentFormSettings-12

    [Documentation]  Update Consent Form Settings - with consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME272}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${PUSERNAME272}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NoAccess}


JD-TC-UpdateConsentFormSettings-13

    [Documentation]  Update Consent Form Settings - update using another provider who dont have an Consent form settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME272}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Provider Consent Form Settings  ${cfid}  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NO_PERMISSION}