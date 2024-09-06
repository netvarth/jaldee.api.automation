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

JD-TC-Get List-1

    [Documentation]  get list,where upload file is appointment
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${Patient}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${Patient}
    ${cnt}=    Get length    ${Patient}
    Set Suite Variable   ${colnames}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME305}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}


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

    ${resp}=  Verify OTP For Patients Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${customerseries[0]}  ${MUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[1]}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}


    ${resp}=  Get List   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()[0]['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['migrationTo']}          ${migrationType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()[0]['migrationStatus']}       Ready


JD-TC-Get List-2

    [Documentation]  get list,where upload file is patient

    ${wb}=  readWorkbook  ${xlFile_patients}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${rowcount}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${rowcount}
    ${cnt}=    Get length    ${rowcount}

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

    ${resp}=  Get List   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()[0]['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['migrationTo']}          ${migrationType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()[0]['migrationStatus']}       Ready

JD-TC-Get List-3

    [Documentation]  get list,where upload file is note


    ${wb}=  readWorkbook  ${xlFile_notes}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${rowcount}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${rowcount}
    ${cnt}=    Get length    ${rowcount}

    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[2]}   ${xlFile_notes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get List   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()[0]['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()[0]['migrationTo']}          ${migrationType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()[0]['migrationStatus']}       Ready



JD-TC-Get List-UH1

    [Documentation]  Get list without login


    ${resp}=  Get List   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}



JD-TC-Get List-UH2

    [Documentation]  Get list using provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get List   ${account_id}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}
