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
${j}                0

*** Keywords ***

Reverse List Using Python
    [Arguments]    ${list}
    ${reversed_list}=    Evaluate    list(reversed(${list}))
    RETURN    ${reversed_list}

*** Test Cases ***

JD-TC-Get Appointment List-1

    [Documentation]  Get Appointment List

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    ${Patient}   getColumnValuesByName  ${sheet1}  ${colnames[0]}

    ${pp}=   Reverse List Using Python   ${Patient}

    # ${reversed_list}=    Set Variable    ${Patient}[::-1]
    # Log    ${reversed_list}

    Set Suite Variable   ${colnames}
    ${AppointmentDate}   getColumnValuesByName  ${sheet1}  ${colnames[1]}
    Log   ${AppointmentDate}
    ${date}=   Reverse List Using Python   ${AppointmentDate}
    # ${AppointmentDate}=    Convert Date    ${AppointmentDate}    result_format=%Y-%m-%d
    ${Notes}   getColumnValuesByName  ${sheet1}  ${colnames[2]}
    Log   ${Notes}

    ${Note}=   Reverse List Using Python   ${Notes}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME313}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME313}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp1}=  Get Appointment List    
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    ${len}  Get Length  ${resp1.json()}

    FOR   ${i}  IN RANGE   ${len-1}   0   -1


        Set Test Variable  ${Apptid${i}}    ${resp1.json()[${i}]['uid']}
        ${resp}=  Get Appointment By Uid    ${Apptid${i}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['account']}            ${account_id}
        Should Be Equal As Strings  ${resp.json()['migrationPatientId']}           ${Patient[${j}]}
        # Should Be Equal As Strings  ${resp.json()['migrationPatientId']}           ${pp[${i}]}
       ${AppointmentDate[${j}]}=    Convert Date    ${AppointmentDate[${j}]}    result_format=%Y-%m-%d
        Should Be Equal As Strings  ${resp.json()['appointmentDate']}          ${AppointmentDate[${j}]}   
        Should Be Equal As Strings  ${resp.json()['notes']}                  ${Notes[${j}]}
        ${j}=  Evaluate  ${j}+1
    END




JD-TC-Get Appointment List-UH1

    [Documentation]  get appointment list without login

    ${resp1}=  Get Appointment List    
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}   419
    Should Be Equal As Strings  ${resp1.json()}       ${SESSION_EXPIRED}  

JD-TC-Get Appointment List-UH3

    [Documentation]  get appointment  list with invalid provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp1}=  Get Appointment List    
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}   200
    Should Be Equal As Strings  ${resp1.content}       ${empty}  








