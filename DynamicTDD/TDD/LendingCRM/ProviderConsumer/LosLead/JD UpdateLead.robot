*** Settings ***
Suite Teardown                  Delete All Sessions
Test Teardown                   Delete All Sessions
Force Tags                      LOS Lead
Library                         Collections
Library                         String
Library                         json
Library                         FakerLibrary
Library                         /ebs/TDD/db.py
Library                         /ebs/TDD/excelfuncs.py
Resource                        /ebs/TDD/ProviderKeywords.robot
Resource                        /ebs/TDD/ConsumerKeywords.robot
Resource                        /ebs/TDD/ProviderConsumerKeywords.robot
Resource                        /ebs/TDD/ProviderPartnerKeywords.robot
Variables                       /ebs/TDD/varfiles/providers.py
Variables                       /ebs/TDD/varfiles/consumerlist.py 
Variables                       /ebs/TDD/varfiles/providers.py
Variables                       /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${losProduct}                    CDL
${aadhaar}                       555555555555
${pan}                           5555555555
${bankAccountNo}                 55555555555
${bankIfsc}                      55555555555

*** Test Cases ***

JD-TC-UpdateLead-1

    [Documentation]             Update Lead - description

    ${resp}=  Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME83}

*** Comments ***  Currently Not Avaliable

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

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
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

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

    # ${requestedAmount}=     Random Int  min=30000  max=600000
    # ${description}=         FakerLibrary.bs
    # ${consumerFirstName}=   FakerLibrary.first_name
    # ${consumerLastName}=    FakerLibrary.last_name  
    # ${dob}=    FakerLibrary.Date
    # ${address}=  FakerLibrary.address
    # ${gender}=  Random Element    ${Genderlist}
    # Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}.${test_mail}   
    # ${permanentAddress1}=   FakerLibrary.address
    # ${permanentAddress2}=   FakerLibrary.address  
    # ${nomineeName}=     FakerLibrary.first_name
    # ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    # ${resp}=    PC Create Lead LOS  ${leadchannel[0]}  ${description}  ${losProduct}  ${requestedAmount}  consumerKyc=${consumerKyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable      ${lead_uid}      ${resp.json()['uid']}

    # ${resp}=    PC Get Lead By Uid LOS   ${lead_uid}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    # Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id}
    # Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    # Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}

    # ${description2}=         FakerLibrary.bs

    # ${resp}=    PC Update Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount}  consumerKyc=${consumerKyc}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    PC Get Lead By Uid LOS   ${lead_uid}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    # Should Be Equal As Strings    ${resp.json()['account']}                             ${account_id}
    # Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    # Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['leadUid']}              ${lead_uid}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerLastName']}     ${consumerLastName}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['dob']}                  ${dob}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['gender']}               ${gender}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['consumerPhone']}        ${consumerPhone}
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeType']}          ${NomineeType[2]}  
    # Should Be Equal As Strings    ${resp.json()['consumerKyc']['nomineeName']}          ${nomineeName}

    ${requestedAmount}=     Random Int  min=30000  max=600000
    Set Suite Variable          ${requestedAmount}
    ${description}=         FakerLibrary.bs
    ${address}=  FakerLibrary.address
    ${permanentAddress2}=   FakerLibrary.address  
    Set Suite Variable          ${permanentAddress2}
    ${nomineeName}=     FakerLibrary.first_name
    Set Suite Variable          ${nomineeName}
    ${consumerKyc}=   Create Dictionary  consumerFirstName=${consumerFirstName}  consumerLastName=${consumerLastName}  dob=${dob}  gender=${gender}  consumerPhoneCode=${countryCodes[1]}   consumerPhone=${consumerPhone}  consumerEmail=${consumerEmail}  aadhaar=${aadhaar}  pan=${pan}  bankAccountNo=${bankAccountNo}  bankIfsc=${bankIfsc}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentDistrict=${permanentDistrict}  permanentState=${permanentState}  permanentPin=${permanentPin}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}
    Set Suite Variable          ${consumerKyc}

    ${resp}=    PC Create Lead LOS  ${leadchannel[0]}  ${description}  ${losProduct}  ${requestedAmount}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable      ${lead_uid}      ${resp.json()['uid']}

    ${resp}=    PC Get Lead By Filter LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()[0]['account']}                             ${accountId}
    Should Be Equal As Strings    ${resp.json()[0]['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()[0]['losProduct']}                          ${losProduct}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerFirstName']}    ${consumerFirstName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerLastName']}     ${consumerLastName}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['dob']}                  ${dob}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['gender']}               ${gender}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhoneCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerPhone']}        ${consumerPhone}
    Should Be Equal As Strings    ${resp.json()[0]['consumerKyc']['consumerEmail']}        ${consumerEmail}


    ${description2}=         FakerLibrary.bs
    Set Suite Variable          ${description2}

    ${resp}=    PC Update Lead LOS  ${lead_uid}  ${description2}  ${losProduct}  ${requestedAmount}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    PC Get Lead By Uid LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['uid']}                                 ${lead_uid}
    Should Be Equal As Strings    ${resp.json()['account']}                             ${accountId}
    Should Be Equal As Strings    ${resp.json()['channel']}                             ${leadchannel[0]}
    Should Be Equal As Strings    ${resp.json()['losProduct']}                          ${losProduct}
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