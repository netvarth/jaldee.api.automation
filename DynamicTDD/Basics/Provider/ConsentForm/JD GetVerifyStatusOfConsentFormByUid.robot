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

${xlFile}    ${EXECDIR}/TDD/ConsentForm.xlsx
${self}    0
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458

*** Test Cases ***

JD-TC-GetVerifyStatusOfConsentFormByUid-1

    [Documentation]  Get Verify Status of consent form by uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
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
    ${fullName}   Set Variable    ${consumerFirstName} ${consumerLastName}
    Set Suite Variable  ${fullName}

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

    ${resp}=    Comsent Form Sent Otp     ${cf_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Comsent Form Verify Otp  {OtpPurpose['CONSENT_FORM']}  ${cf_uid}   ${consumerPhone}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}=    upload file to temporary location consumer    ${file_action[0]}    ${consumerId}    ${ownerType[0]}    ${fullName}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}=    Consent Form Verify Sign  ${cf_uid}  ${consumerId}  ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}  ${file_action[0]}  ${order}  ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[1]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH1

    [Documentation]  Get Verify Status of consent form by uid - after share consent form

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number2}    Random Number 	       digits=5 
    ${PH_Number2}=    Evaluate    f'{${PH_Number2}:0>7d}'
    Log  ${PH_Number2}
    Set Suite Variable    ${consumerPhone2}  555${PH_Number2}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone2}${\n}
    ${consumerFirstName2}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName2}
    ${consumerLastName2}=    FakerLibrary.last_name  
    ${dob2}=    FakerLibrary.Date
    ${permanentAddress11}=  FakerLibrary.address
    ${gender2}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail2}  ${C_Email}${consumerPhone2}${consumerFirstName2}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone2}  firstName=${consumerFirstName2}   lastName=${consumerLastName2}  address=${permanentAddress11}   gender=${gender2}  dob=${dob2}  email=${consumerEmail2}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${consumerId2}  ${resp.json()[0]['id']}
    ${fullName2}   Set Variable    ${consumerFirstName2} ${consumerLastName2}
    Set Suite Variable  ${fullName2}

    ${qnr_name2}=    FakerLibrary.name
    Set Suite Variable  ${qnr_name2}
    ${qnr_des2}=     FakerLibrary.sentence
    Set Suite Variable  ${qnr_des2}
    ${qnr_ids}=     Create List  ${qnr_id}
    Set Suite Variable   ${qnr_ids}

    ${resp}=    Create Provider Consent Form Settings  ${qnr_name2}  ${qnr_des2}  ${qnr_ids}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Consent Form Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${cfid2}     ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.json()[1]['name']}           ${qnr_name2}
    Should Be Equal As Strings  ${resp.json()[1]['description']}    ${qnr_des2}
    Should Be Equal As Strings  ${resp.json()[1]['qnrIds']}         ${qnr_ids}

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid2}  ${boolean[1]}  ${boolean[1]}  ${consumerId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cf_uid2}   ${resp.json()}

    ${resp}=    Get Consent Form By Uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[0]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH2

    [Documentation]  Get Verify Status of consent form by uid - after send otp

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Comsent Form Sent Otp     ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[0]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH3

    [Documentation]  Get Verify Status of consent form by uid - after verify otp

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Comsent Form Sent Otp     ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Comsent Form Verify Otp  {OtpPurpose['CONSENT_FORM']}  ${cf_uid2}   ${consumerPhone2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[0]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH4

    [Documentation]  Get Verify Status of consent form by uid - after verify sign

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}=    upload file to temporary location consumer    ${file_action[0]}    ${consumerId2}    ${ownerType[0]}    ${fullName2}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}=    Consent Form Verify Sign  ${cf_uid2}  ${consumerId2}  ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}  ${file_action[0]}  ${order}  ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[1]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH5

    [Documentation]  Get Verify Status of consent form by uid - where is sign req is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Share Consent Form  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${cfid2}  ${boolean[1]}  ${boolean[0]}  ${consumerId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cf_uid3}   ${resp.json()}

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}       ${bool[1]}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH6

    [Documentation]  Get Verify Status of consent form by uid - without login

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}

JD-TC-GetVerifyStatusOfConsentFormByUid-UH7

    [Documentation]  Get Verify Status of consent form by uid - uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME287}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Verify Status of consent form by uid  ${cf_uid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}
