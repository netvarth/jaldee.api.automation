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

JD-TC-Get Appointment By Uid-1

    [Documentation]  Get Appointment by uid

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${Patient}   getColumnValuesByName  ${sheet1}  ${colnames[0]}
    Log   ${Patient[28]}
    ${cnt}=    Get length    ${Patient}
    Set Suite Variable   ${colnames}
    ${AppointmentDate}   getColumnValuesByName  ${sheet1}  ${colnames[1]}
    Log   ${AppointmentDate}
    ${date}=    Convert Date    ${AppointmentDate[28]}    result_format=%Y-%m-%d
    ${Notes}   getColumnValuesByName  ${sheet1}  ${colnames[2]}
    Log   ${Notes}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME312}  ${PASSWORD}
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

    ${resp}=  Verify OTP For Patients Migration     ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${customerseries[0]}  ${MUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[1]}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP For Appointment Migration   ${account_id}      ${DMUID}    ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify OTP For Appointment Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}    ${DMUID}   ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s

    ${resp}=  Encrypted Provider Login  ${PUSERNAME312}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Get Appointment List    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${Apptid}  ${resp.json()[0]['uid']}

    ${resp}=  Get Appointment By Uid    ${Apptid}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                  ${cnt}
    Should Be Equal As Strings  ${resp.json()['account']}            ${account_id}
    Should Be Equal As Strings  ${resp.json()['migrationPatientId']}           ${Patient[28]}
    Should Be Equal As Strings  ${resp.json()['appointmentDate']}          ${date}
    Should Be Equal As Strings  ${resp.json()['notes']}                  ${Notes[28]}

JD-TC-Get Appointment By Uid-UH1

    [Documentation]  get appointment with invalid uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME312}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Get Appointment By Uid    ${fake}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_APPT_DATAIMPORTARCHIVE_UID}  

JD-TC-Get Appointment By Uid-UH2

    [Documentation]  get appointment without login

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Get Appointment By Uid    ${fake}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}  

JD-TC-Get Appointment By Uid-UH3

    [Documentation]  get appointment with invalid uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Uid    ${Apptid}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.json()}       ${NO_PERMISSION}  








