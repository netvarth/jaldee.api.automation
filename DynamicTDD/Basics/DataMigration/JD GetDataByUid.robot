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

JD-TC-GetByUid-1

    [Documentation]  Get appointment file data by uid 
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${Patient}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${Patient}
    ${cnt}=    Get length    ${Patient}
    Set Suite Variable   ${colnames}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
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

    ${resp}=  Verify OTP For Patients Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${customerseries[0]}  ${MUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[1]}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}


    ${resp}=  Get Data By Uid   ${account_id}   ${DMUID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()['migrationTo']}          ${migrationType[1]}
    Should Be Equal As Strings  ${resp.json()['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()['migrationStatus']}       Ready


JD-TC-GetByUid-2

    [Documentation]  Get patient file data by uid 

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

    ${resp}=  Get Data By Uid   ${account_id}   ${DMUID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()['migrationTo']}          ${migrationType[0]}
    Should Be Equal As Strings  ${resp.json()['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()['migrationStatus']}       Ready

JD-TC-GetByUid-3

    [Documentation]  Get note file data by uid 


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

    ${resp}=  Get Data By Uid   ${account_id}   ${DMUID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                  ${DMUID}
    Should Be Equal As Strings  ${resp.json()['account']}              ${account_id}
    Should Be Equal As Strings  ${resp.json()['createdDate']}          ${DAY}
    Should Be Equal As Strings  ${resp.json()['migrationTo']}          ${migrationType[2]}
    Should Be Equal As Strings  ${resp.json()['totalCount']}           ${cnt}
    Should Be Equal As Strings  ${resp.json()['migrationStatus']}       Ready


JD-TC-GetByUid-UH1

    [Documentation]  Get data by invalid uid

    ${fake}=  FakerLibrary.Random Number
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Data By Uid   ${account_id}   ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-GetByUid-UH2

    [Documentation]  Get data by  uid without login


    ${resp}=  Get Data By Uid   ${account_id}   ${DMUID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-GetByUid-UH3

    [Documentation]  Get data by invalid uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Get Data By Uid   ${account_id1}   ${fake}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-GetByUid-UH4

    [Documentation]  Get data busing provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Data By Uid   ${account_id1}   ${DMUID}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
   Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}
