*** Settings ***
Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         LOS Lead
Library            Collections
Library            String
Library            json
Library            FakerLibrary
Library            /ebs/TDD/db.py
Library            /ebs/TDD/excelfuncs.py
Resource           /ebs/TDD/ProviderKeywords.robot
Resource           /ebs/TDD/ConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${losProduct}                    CDL
${aadhaar}                       555555555555
${pan}                           5555555555
${bankAccountNo}                 55555555555
${bankIfsc}                      55555555555

*** Test Cases ***

JD-TC-GetAuditLogorHistory-1

    [Documentation]             Get Audit Log Or History

    ${resp}=   Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id1}       ${resp.json()['id']}

    FOR    ${i}    IN RANGE  0  3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =   Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable  ${city}      ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${permanentState}     ${resp.json()[0]['PostOffice'][0]['State']}    
    Set Suite Variable  ${permanentDistrict}  ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${permanentPin}       ${resp.json()[0]['PostOffice'][0]['Pincode']}

    ${Sname}=    FakerLibrary.name
    Set Suite Variable      ${Sname}

    ${resp}=    Create Lead Status LOS  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${status_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Sname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

    ${Pname}=    FakerLibrary.name
    Set Suite Variable      ${Pname}

    ${resp}=    Create Lead Progress LOS  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${progress_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Pname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone}  555${PH_Number}
    ${requestedAmount}=     Random Int  min=30000  max=600000
    ${description}=         FakerLibrary.bs
    ${consumerFirstName}=   FakerLibrary.first_name
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${address}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}.${test_mail}   
    ${permanentAddress1}=   FakerLibrary.address
    ${permanentAddress2}=   FakerLibrary.address  
    ${nomineeName}=     FakerLibrary.first_name
    ${status}=  Create Dictionary  id=${status_id}  name=${Sname}
    ${progress}=  Create Dictionary  id=${progress_id}  name=${Pname}
    ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${losProduct}  ${requestedAmount}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${lead_uid}      ${resp.json()['uid']}

    ${resp}=    Get Audit Log or History LOS  ${lead_uid} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['account']}     ${account_id1}
    Should Be Equal As Strings    ${resp.json()['leadUid']}     ${lead_uid}

JD-TC-GetAuditLogorHistory-UH1

    [Documentation]             Get Audit Log Or History- lead uid is invalid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=999  max=9999

    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   Lead

    ${resp}=    Get Audit Log or History LOS  ${fake} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}

JD-TC-GetAuditLogorHistory-UH2

    [Documentation]             Get Audit Log Or History- without login

    ${resp}=    Get Audit Log or History LOS  ${lead_uid} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-GetAuditLogorHistory-UH3

    [Documentation]             Get Audit Log Or History- with another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   lead

    ${resp}=    Get Audit Log or History LOS  ${lead_uid} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}