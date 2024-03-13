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

JD-TC-ShareConsentForm-1

    [Documentation]  Share Consent Form

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
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

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${consumerId}  ${resp.json()[0]['id']}

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

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cf_uid}   ${resp.json()}

    ${resp}=    Get Consent Form By Uid  ${cf_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}        ${qnr_name}
    Should Be Equal As Strings  ${resp.json()['uid']}         ${cf_uid}
    Should Be Equal As Strings  ${resp.json()['status']}      ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['settingId']}   ${cfid}

JD-TC-ShareConsentForm-UH1

    [Documentation]  Share Consent Form - where email is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH2

    [Documentation]  Share Consent Form - where sms is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH3

    [Documentation]  Share Consent Form - where push notoficaton is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH4

    [Documentation]  Share Consent Form - where whats app is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[0]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH5

    [Documentation]  Share Consent Form -where consetForm Setting Id is empty 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${empty}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INVALID_INPUT_FORMAT}

JD-TC-ShareConsentForm-UH6

    [Documentation]  Share Consent Form - where consetForm Setting Id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=11111  max=99999

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${fake}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INV_CONSENT_FORM_ID}

JD-TC-ShareConsentForm-UH7

    [Documentation]  Share Consent Form - where isSignatureRequired false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[0]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH8

    [Documentation]  Share Consent Form - where isOtpRequired false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[0]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareConsentForm-UH9

    [Documentation]  Share Consent Form - where provider consumer id is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INVALID_INPUT_FORMAT}

JD-TC-ShareConsentForm-UH10

    [Documentation]  Share Consent Form - where provider consumer id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=11111  max=99999

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INVALID_TASK_ID}

JD-TC-ShareConsentForm-UH11

    [Documentation]  Share Consent Form - without login

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}      ${SESSION_EXPIRED}

JD-TC-ShareConsentForm-UH12

    [Documentation]  Share Consent Form - with SA Login

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}      ${SESSION_EXPIRED}

JD-TC-ShareConsentForm-UH13

    [Documentation]  Share Consent Form - Where Consent Form Settings is Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME275}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable Provider Consent Form  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableConsentForm']}     ${bool[0]}

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid}  ${boolean[1]}  ${boolean[1]}  ${consumerId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
