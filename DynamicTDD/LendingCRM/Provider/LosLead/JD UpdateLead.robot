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

${invaadhaar2}                    55557896541
${invpan2}                        555587965
${bankAccountNo2}                 55558748
${bankIfsc2}                      5555554875

${aadhaar2}                       555554855555
${pan2}                           5555585555

${pin2}                           680623

*** Test Cases ***

JD-TC-ChangeLeadStatus-1

    [Documentation]             Update Lead - description
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
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
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable          ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    Set Suite Variable          ${consumerLastName}
    ${dob}=    FakerLibrary.Date
    Set Suite Variable          ${dob}
    ${permanentAddress1}=  FakerLibrary.address
    Set Suite Variable          ${permanentAddress1}
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable          ${gender}
    Set Suite Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${consumerId}  ${resp.json()[0]['id']}
    Should Be Equal As Strings    ${resp.json()[0]['id']}  ${consumerId}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}  ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}  ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['email']}  ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()[0]['gender']}  ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['dob']}  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['status']}  ${status[0]}
    Should Be Equal As Strings    ${resp.json()[0]['favourite']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['phone_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['email_verified']}  ${bool[0]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['whatsAppNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['countryCode']}  ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['telegramNum']['number']}  ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['age']['year']}  ${ageyrs}
    Should Be Equal As Strings    ${resp.json()[0]['age']['month']}  ${agemonths}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id1}

    ${requestedAmount}=     Random Int  min=30000  max=600000
    Set Suite Variable          ${requestedAmount}
    ${description}=         FakerLibrary.bs
    ${address}=  FakerLibrary.address
    ${permanentAddress2}=   FakerLibrary.address  
    Set Suite Variable          ${permanentAddress2}
    ${nomineeName}=     FakerLibrary.first_name
    Set Suite Variable          ${nomineeName}
    ${status}=  Create Dictionary  id=${status_id}  name=${Sname}
    Set Suite Variable          ${status}
    ${progress}=  Create Dictionary  id=${progress_id}  name=${Pname}
    Set Suite Variable          ${progress}
    ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}
    Set Suite Variable          ${consumerKyc}

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


    ${description2}=         FakerLibrary.bs
    Set Suite Variable          ${description2}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-2

    [Documentation]             Update Lead - requested amoumt
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${requestedAmount2}=     Random Int  min=30000  max=600000
    Set Suite Variable          ${requestedAmount2}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


# JD-TC-ChangeLeadStatus-3

#     [Documentation]             Update Lead - status changed - cant change by the user
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${Sname2}=    FakerLibrary.name
#     Set Suite Variable      ${Sname2}

#     ${resp}=    Create Lead Status LOS  ${Sname2}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Set Suite Variable      ${status_id2}      ${resp.json()['id']}

#     ${resp}=    Get Lead Status LOS
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id2}
#     Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Sname2}
#     Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

#     ${status2}=  Create Dictionary  id=${status_id2}  name=${Sname2}
#     Set Suite Variable          ${status2}

#     ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status2}  progress=${progress}  consumerKyc=${consumerKyc}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${resp}=    Get Lead LOS   ${lead_uid}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200
#     Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
#     Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
#     Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
#     Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
#     Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id2}
#     Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname2}
#     Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
#     Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
#     Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
#     Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-4

    [Documentation]             Update Lead - firatname is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${empty}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-5

    [Documentation]             Update Lead - lastname is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${empty}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}

JD-TC-ChangeLeadStatus-6

    [Documentation]             Update Lead - dob is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${empty}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


# JD-TC-ChangeLeadStatus-7

#     [Documentation]             Update Lead - gender is empty - enum value cant be empty
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${empty}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

#     ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   500


JD-TC-ChangeLeadStatus-8

    [Documentation]             Update Lead - phonecode is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${empty}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-9

    [Documentation]             Update Lead - phone is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${empty}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-10

    [Documentation]             Update Lead - email is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${empty}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-11

    [Documentation]             Update Lead - aadhar is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${empty}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}



JD-TC-ChangeLeadStatus-12

    [Documentation]             Update Lead - pan is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${empty}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-13

    [Documentation]             Update Lead - account number is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${empty}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}



JD-TC-ChangeLeadStatus-14

    [Documentation]             Update Lead - ifsc is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${empty}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-15

    [Documentation]             Update Lead - address 1 is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${empty}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-16

    [Documentation]             Update Lead - address2 is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${empty}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-17

    [Documentation]             Update Lead - district is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${empty}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-18

    [Documentation]             Update Lead - state is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${empty}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-19

    [Documentation]             Update Lead - pin is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${empty}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


# JD-TC-ChangeLeadStatus-20

#     [Documentation]             Update Lead - nominee type is empty - enum value cant be empty
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   200

#     ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${empty}  nomineeName=${nomineeName}

#     ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}   500


JD-TC-ChangeLeadStatus-21

    [Documentation]             Update Lead - nominee name is empty
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${empty}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-22

    [Documentation]             Update Lead - firatname is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname}=    FakerLibrary.firstname
    Set Suite Variable          ${fname}

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${fname}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-23

    [Documentation]             Update Lead - lastname is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${lname}=    FakerLibrary.firstname
    Set Suite Variable          ${lname}

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${lname}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}

JD-TC-ChangeLeadStatus-24

    [Documentation]             Update Lead - dob is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${dob2}=    FakerLibrary.Date
    Set Suite Variable          ${dob2}

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob2}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-25

    [Documentation]             Update Lead - gender is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${Genderlist[1]}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-26

    [Documentation]             Update Lead - phonecode is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[2]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-27

    [Documentation]             Update Lead - phone is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone2}  555${PH_Number}

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone2}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-28

    [Documentation]             Update Lead - email is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable  ${consumerEmail2}  ${C_Email}${consumerPhone}${fname}.${test_mail}

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail2}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-29

    [Documentation]             Update Lead - account number is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo2}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}



JD-TC-ChangeLeadStatus-30

    [Documentation]             Update Lead - ifsc is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc2}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-31
 
    [Documentation]             Update Lead - address 1 is changed  - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${a1}=      FakerLibrary.address

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${a1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-32

    [Documentation]             Update Lead - address2 is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${a1}=      FakerLibrary.address

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${a1}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-33

    [Documentation]             Update Lead - district is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${a1}=      FakerLibrary.address

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${a1}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-34

    [Documentation]             Update Lead - state is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${a1}=      FakerLibrary.address

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${a1}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-35

    [Documentation]             Update Lead - nominee type is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-36

    [Documentation]             Update Lead - nominee name is changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${nname}=   FakerLibrary.firstname

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nname}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}



JD-TC-ChangeLeadStatus-37

    [Documentation]             Update Lead - aadhar number changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar2}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-38

    [Documentation]             Update Lead - pan number changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan2}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-39

    [Documentation]             Update Lead - pincode number changed - kyc details will not update , to update kyc details of consumer call update customer
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan2}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${pin2}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id1}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()['status']['id']}                        ${status_id}
    Should Be Equal As Strings    ${resp.json()['status']['name']}                      ${Sname}
    Should Be Equal As Strings    ${resp.json()['progress']['id']}                      ${progress_id}
    Should Be Equal As Strings    ${resp.json()['progress']['name']}                    ${Pname}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerId']}           ${consumerId}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerEmail']}        ${consumerEmail}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress1']}    ${permanentAddress1}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentAddress2']}    ${permanentAddress2}
    Should Be Equal As StringS    ${resp.json()['consumerKyc']['permanentDistrict']}    ${permanentDistrict}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentState']}       ${permanentState}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['permanentPin']}         ${permanentPin}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['aadhaar']}              ${aadhaar}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['pan']}                  ${pan}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankAccountNo']}        ${bankAccountNo}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['bankIfsc']}             ${bankIfsc}
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}


JD-TC-ChangeLeadStatus-UH1

    [Documentation]             Update Lead - aadhar is changed with invalid aadhar number 11 digit
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${invaadhaar2}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_AADHAAR_NUMBER}


JD-TC-ChangeLeadStatus-UH2

    [Documentation]             Update Lead - pan is changed with invlid value
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${invpan2}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_PAN}

JD-TC-ChangeLeadStatus-UH3

    [Documentation]             Update Lead - pin is changed with invalid value 5 digit
    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pin3}=    FakerLibrary.Postalcode

    ${consumerKyc2}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${pin3}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${INVALID_PIN_LOS}


JD-TC-ChangeLeadStatus-UH4

    [Documentation]             Update Lead - without login

    ${resp}=    Updtae Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount2}  status=${status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}