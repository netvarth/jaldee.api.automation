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
Variables          /ebs/TDD/varfiles/musers.py
Variables          /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

${losProduct}                    CDL
${aadhaar}                       555555555555
${pan}                           5555555555
${bankAccountNo}                 55555555555
${bankIfsc}                      55555555555

*** Test Cases ***

JD-TC-ChangeLeadCreditStatus-1

    [Documentation]             Change lead Credit Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD} 
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

    ${resp}=    Get Lead By Filter LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()[0]['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()[0]['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()[0]['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()[0]['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerEmail']}        ${consumerEmail}

    ${Cname}=    FakerLibrary.name

    ${resp}=    Create Lead Credit Status LOS  ${Cname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${creditstatus}      ${resp.json()['id']}

    ${resp}=    Get Lead Credit Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${creditstatus}
    Should Be Equal As Strings    ${resp.json()[0]['account']}      ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Cname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

    ${resp}=    Change Lead Credit Status LOS   ${lead_uid}  ${creditstatus} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead By Filter LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()[0]['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()[0]['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()[0]['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()[0]['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()[0]['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()[0]['creditStatus']['id']}                  ${creditstatus}
    Should Be Equal As Strings    ${resp.json()[0]['creditStatus']['name']}                ${Cname}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerEmail']}        ${consumerEmail}


JD-TC-ChangeLeadCreditStatus-UH1

    [Documentation]             Change Lead Credit Status where lead_uid is invalid 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999

    ${INVALID_LEAD_ID}=   Replace String  ${INVALID_LEAD_ID}  {}  Lead

    ${resp}=    Change Lead Credit Status LOS  ${fake}  ${creditstatus} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_LEAD_ID}

JD-TC-ChangeLeadCreditStatus-UH2

    [Documentation]             Change Lead Credit Status where progress is invalid 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fake}=    Random Int  min=300  max=999

    ${INVALID_X_ID}=   Replace String  ${INVALID_X_ID}  {}   Credit Status

    ${resp}=    Change Lead Credit Status LOS  ${lead_uid}  ${fake} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_X_ID}

JD-TC-ChangeLeadCreditStatus-UH3

    [Documentation]             Change Lead Credit Status without login

    ${resp}=    Change Lead Credit Status LOS  ${lead_uid}  ${creditstatus} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-ChangeLeadCreditStatus-UH4

    [Documentation]             Change Lead Credit Status using another provider login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${NO_PERMISSION_X}=   Replace String  ${NO_PERMISSION_X}  {}   lead

    ${resp}=    Change Lead Credit Status LOS  ${lead_uid}  ${creditstatus} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION_X}