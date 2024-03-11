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
Variables         /ebs/TDD/varfiles/properties.py
Library           /ebs/TDD/excelfuncs.py


*** Variables ***
${xlFile}    ${EXECDIR}/TDD/Data_Migration_Appointments.xlsx
${xlFile_patients}    ${EXECDIR}/TDD/Data_Migration_Patients.xlsx
${xlFile_notes}    ${EXECDIR}/TDD/Data_Migration_Notes.xlsx
${xlFile_invalid}    ${EXECDIR}/TDD/ConsentForm.xlsx


*** Test Cases ***

JD-TC-Generate OTP For Notes Migration-1

    [Documentation]  Generate OTP For Notes Migration

    ${resp}=  Encrypted Provider Login  ${PUSERNAME308}  ${PASSWORD}
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
    Set Suite Variable          ${MUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[0]}   ${MUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Verify OTP For Patients Migration     ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${customerseries[0]}  ${MUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[2]}   ${xlFile_notes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP For Notes Migration   ${account_id}      ${DMUID}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


   
JD-TC-Generate OTP For Notes Migration-UH1

    [Documentation]  Generate OTP For Notes Migration where upload file is appointment
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid1}    ${resp}  

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}  

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id1}   ${migrationType[0]}   ${xlFile_patients}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${MUID1}  ${resp.json()['${account_id1}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id1}   ${customerseries[0]}   ${MUID1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify OTP For Patients Migration     ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id1}   ${customerseries[0]}  ${MUID1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id1}   ${migrationType[1]}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable          ${DMUID1}  ${resp.json()['${account_id1}']}


    ${resp}=  Generate OTP For Notes Migration   ${account_id1}     ${DMUID1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Generate OTP For Notes Migration-UH2

    [Documentation]  Generate OTP For Notes Migration where provider is different

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP For Notes Migration   ${account_id1}      ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422



JD-TC-Generate OTP For Notes Migration-UH3

    [Documentation]  Generate OTP For Notes Migration without login


    ${resp}=  Generate OTP For Notes Migration   ${account_id}     ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-Generate OTP For Notes Migration-UH4

    [Documentation]  Generate OTP For Notes Migration wusing provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME308}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Generate OTP For Notes Migration   ${account_id}    ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}

JD-TC-Generate OTP For Notes Migration-UH5

    [Documentation]  Generate OTP For Notes Migration using patient migration id


    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP For Notes Migration   ${account_id}    ${MUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}