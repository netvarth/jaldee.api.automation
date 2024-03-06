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
Resource          /ebs/TDD/Keywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/excelfuncs.py


*** Variables ***
${xlFile}    ${EXECDIR}/TDD/Data_Migration_Appointments.xlsx
${xlFile_patients}    ${EXECDIR}/TDD/Data_Migration_Patients.xlsx
${xlFile_notes}    ${EXECDIR}/TDD/Data_Migration_Notes.xlsx
${xlFile_invalid}    ${EXECDIR}/TDD/ConsentForm.xlsx
@{customerIdFormat}       AUTO  MANUAL

*** Keywords ***


Get Data By Uid
    [Arguments]     ${account}  ${uid}
    Check And Create YNW SuperAdmin Session
    ${resp}=  GET On Session  synw  /spdataimport/account/${account}/${uid}   expected_status=any
    RETURN  ${resp}

Generate OTP for patient migration
   [Arguments]    ${account}  ${customerIdFormat}  ${uid}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerIdFormat}/Patients/migrate/${uid}/generateotp    expected_status=any
   RETURN  ${resp}

Verify OTP For Patients Migration
   [Arguments]    ${account}  ${customerIdFormat}  ${uid}  ${otp}
   Check And Create YNW SuperAdmin Session
   ${resp}=  POST On Session   synw   /spdataimport/account/${account}/${customerIdFormat}/Patients/migrate/${uid}/verifyotp/${otp}    expected_status=any
   RETURN  ${resp}

*** Test Cases ***

JD-TC-Generate OTP for patient migration-1

    [Documentation]  Get appointment file data by uid 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME301}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[0]}   ${xlFile_patients}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerIdFormat[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify OTP For Patients Migration   ${account_id}   ${customerIdFormat[0]}   ${DMUID}   ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
