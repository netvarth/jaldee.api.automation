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

JD-TC-Verify OTP For Notes Migration-1

    [Documentation]  Verify OTP For Notes Migration

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
    Set Suite Variable          ${DMUID}  ${resp.json()['${account_id}']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate OTP for patient migration   ${account_id}   ${customerseries[0]}   ${DMUID}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify OTP For Patients Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${customerseries[0]}  ${DMUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Imageupload.DataMigrationUpload   ${cookie}   ${account_id}   ${migrationType[2]}   ${xlFile_notes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable          ${NMUID}  ${resp.json()['${account_id}']}

    ${resp}=  Generate OTP For Notes Migration   ${account_id}      ${NMUID}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}     ${NMUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Verify OTP For Notes Migration-UH1

    [Documentation]  Verify OTP For Notes Migration with empty phone number

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Verify OTP For Notes Migration    ${empty}   ${OtpPurpose['SPDataImport']}     ${account_id}   ${NMUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${ENTER_VALID_OTP} 


JD-TC-Verify OTP For Notes Migration-UH2

    [Documentation]  Verify OTP For Notes Migration where purpose is given as wrong

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['ProviderSignUp']}     ${account_id}    ${NMUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${ENTER_VALID_OTP}  

JD-TC-Verify OTP For Notes Migration-UH3

    [Documentation]  Verify OTP For Notes Migration where account id is wrong

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${fake}     ${NMUID}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${Invalid_account_id}  


JD-TC-Verify OTP For Notes Migration-UH5

    [Documentation]  Verify OTP For Notes Migration where uid is wrong

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}     ${fake}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_DATAIMPORT_ID}  


JD-TC-Verify OTP For Notes Migration-UH6

    [Documentation]  Verify OTP For Notes Migration without login

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}    ${fake}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}


JD-TC-Verify OTP For Notes Migration-UH7

    [Documentation]  Verify OTP For Notes Migration using provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME303}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Random Int  min=1000000   max=9999999

    ${resp}=  Verify OTP For Notes Migration    ${spdataimport}   ${OtpPurpose['SPDataImport']}     ${account_id}     ${fake}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SA_SESSION_EXPIRED}





