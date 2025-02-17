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

${jpg}     /ebs/TDD/small.jpg

*** Test Cases ***

JD-TC-GetReleasedQuestionnaireByUuid-1

    [Documentation]  Get released questionnaire by uuid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
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
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
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

    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  200
    Set Suite Variable     ${Quid}  ${respo.json()[0]['id']}


JD-TC-GetReleasedQuestionnaireByUuid-2

    [Documentation]  Get released questionnaire by uuid - after submitting Qnr

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  200
    Set Suite Variable     ${Quid}  ${respo.json()[0]['id']}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME303}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption}     FakerLibrary.firstName
    ${file_size}    Get File Size    ${jpg}
    ${labelName}    FakerLibrary.firstName
    ${resp}=    db.getMimetype   ${jpg}
    ${mimetype}    Get From Dictionary    ${resp}    ${jpg}
    ${keyName}    FakerLibrary.firstName  
    ${file_name}    Evaluate    __import__('os').path.basename('${jpg}')

    ${resp}=    Imageupload.UploadQNRfiletoTempLocation    ${cookie}  ${user_id}  ${Quid}  ${caption}  ${mimetype}  ${file_name}  ${file_name}  ${file_size}  ${labelName}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Set Suite Variable    ${driveid}     ${resp.json()['urls'][0]['driveId']}

    ${fudata}=  db.fileUploadDT   ${respo.json()[0]}  ${FileAction[0]}  ${cf_uid}  ${jpg} 
    Log  ${fudata}

    ${len}=  Get Length  ${fudata['fileupload'][0]['files']}
    FOR  ${i}  IN RANGE  0    ${len}
        Set To Dictionary    ${fudata['fileupload'][0]['files'][${i}]}    driveid    ${driveid}
    END

    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${respo.json()[0]}   ${Quid}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=    Provider Consent Form Submit Qnr   ${account_id}    ${cf_uid}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  200


JD-TC-GetReleasedQuestionnaireByUuid-3

    [Documentation]  Get released questionnaire by uuid - after resubmitting Qnr

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Provider Consent Form Resubmit Qnr  ${account_id}    ${cf_uid}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  200


JD-TC-GetReleasedQuestionnaireByUuid-UH1

    [Documentation]  Get released questionnaire by uuid - without login

    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  419
    Should Be Equal As Strings  ${respo.json()}  ${SESSION_EXPIRED}

JD-TC-GetReleasedQuestionnaireByUuid-UH2

    [Documentation]  Get released questionnaire by uuid - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=9999    max=99999
    
    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${fake}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  422
    Should Be Equal As Strings  ${resp.json()}      ${INV_CONSENT_FORM_ID}

JD-TC-GetReleasedQuestionnaireByUuid-UH3

    [Documentation]  Get released questionnaire by uuid - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME304}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${respo}=    Provider Consent Form Get released questionnaire by uuid  ${cf_uid}
    Log  ${respo.content}
    Should Be Equal As Strings  ${respo.status_code}  401
    Should Be Equal As Strings  ${respo.json()}  ${NO_PERMISSION_To}