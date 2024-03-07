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


*** Test Cases ***

JD-TC-Generate OTP for patient migration-1

    [Documentation]  Generate OTP for patient migration

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
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

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Generate OTP for patient migration-2

    [Documentation]  Generate OTP for patient migration where patient id is manual

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Create Sample Location  
    Set Test Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${DAY}  

   ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[0]}   ${xlFile_patients}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[1]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Generate OTP for patient migration-UH1

    [Documentation]  Generate OTP for patient migration where customerid format is manual



    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[1]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${CHANGE_PATIENTID_FORMAT}  

   
JD-TC-Generate OTP for patient migration-UH2

    [Documentation]  Generate OTP for patient migration where upload file is appointment
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
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

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[1]}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id1}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Generate OTP for patient migration-UH3

    [Documentation]  Generate OTP for patient migration where provider is different

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id1}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422



JD-TC-Generate OTP for patient migration-UH4

    [Documentation]  Generate OTP for patient migration without login


    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-Generate OTP for patient migration-UH5

    [Documentation]  Generate OTP for patient migration wusing provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}