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
Resource           /ebs/TDD/ProviderConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{sort_order}       1  2  3  4  5  6  7  8  9
${aadhaar}          555555555555
${pan}              5555555555
${bankAccountNo}    55555555555
${bankIfsc}         55555555555


*** Test Cases ***

JD-TC-WorkFlowLosLead-1

    [Documentation]  WorkFlow Los Lead

    ${resp}=   Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END
    Set Test Variable  ${provider_name}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable                    ${account_id}       ${resp.json()['id']}

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
    Set Test Variable  ${city}      ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${permanentState}     ${resp.json()[0]['PostOffice'][0]['State']}    
    Set Test Variable  ${permanentDistrict}  ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${permanentPin}       ${resp.json()[0]['PostOffice'][0]['Pincode']}

#...... Creating Lead status ........

    ${Sname}=    FakerLibrary.name

    ${resp}=    Create Lead Status LOS  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable      ${status_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Status LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${status_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Sname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

#...... Creating Lead Progress ........

    ${Pname}=    FakerLibrary.name

    ${resp}=    Create Lead Progress LOS  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable      ${progress_id}      ${resp.json()['id']}

    ${resp}=    Get Lead Progress LOS
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['id']}           ${progress_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}         ${Pname}
    Should Be Equal As Strings    ${resp.json()[0]['status']}       ${toggle[0]}

#...... Creating Lead Product ........

    ${Pdtname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pdtname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid}     ${resp.json()['uid']}

    ${resp}=    Get Los Product By UID  ${productuid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}           200
    Should Be Equal As Strings    ${resp.json()['uid']}         ${productuid}
    Should Be Equal As Strings    ${resp.json()['account']}     ${account_id}
    Should Be Equal As Strings    ${resp.json()['name']}        ${Pdtname}
    Should Be Equal As Strings    ${resp.json()['losProduct']}  ${losProduct[0]}
    Should Be Equal As Strings    ${resp.json()['status']}      ${toggle[0]}

#...... Creating Lead Sourcing Channel ........

    ${SCname}=    FakerLibrary.name

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel By UID  ${sourcinguid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()['status']}   ${toggle[0]}

# ...... Creating stages followUp, Kyc, Kyc verification and salesfield ....... 

    ${Sname11}=    FakerLibrary.name
    Set Suite Variable  ${Sname11}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname11}  sortOrder=${sort_order[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid11}     ${resp.json()['uid']}

    ${Sname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[2]}  ${Sname22}  sortOrder=${sort_order[1]}  onRedirect=${stageuid11}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid22}     ${resp.json()['uid']}

    ${Sname33}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[3]}  ${Sname33}  sortOrder=${sort_order[2]}  onRedirect=${stageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid33}     ${resp.json()['uid']}

    ${Sname44}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[3]}  ${Sname44}  sortOrder=${sort_order[3]}  onRedirect=${stageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid44}     ${resp.json()['uid']}

# ..... updating stages redirect and proceed uids ........

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid11}  ${Sname11}  onProceed=${stageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid11} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid22}  ${Sname22}  onProceed=${stageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid33}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid11}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${stageuid33}  ${Sname33}  onProceed=${stageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid33} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid44}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid22}

    ${resp}=    Get Los Stage
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# .....  Add customer .........

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}

# ...... Create Lead For Los ...........

    ${requestedAmount}=     Random Int  min=30000  max=600000
    ${description}=         FakerLibrary.bs
    ${permanentAddress2}=   FakerLibrary.address  
    ${nomineeName}=     FakerLibrary.first_name
    ${cdl_status}=  Create Dictionary  id=${status_id}  name=${Sname}
    ${progress}=  Create Dictionary  id=${progress_id}  name=${Pname}
    ${product}=  Create Dictionary  uid=${productuid}
    ${sourcingChannel}=  Create Dictionary  uid=${sourcinguid} 

    ${consumerKyc}=   Create Dictionary  consumerId=${consumerId}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${requestedAmount}    product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lead_uid}     ${resp.json()['uid']}
    Set Suite variable  ${lead}         ${resp.json()}

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# ...... LOS Lead As Draft For Followup Stage ...........

    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}
    ${lead}=    Create Dictionary  product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  requestedAmount=${requestedAmount}  description=${description}  consumerKyc=${consumerKyc}
    Set Suite Variable  ${lead}

    ${resp}=    LOS Lead As Draft For Followup Stage  ${lead_uid}  ${stageuid11}  remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# ...... Save And Proceed LOS Lead Followup ...........

    ${resp}=    Save And Proceed LOS Lead Followup  ${lead_uid}  ${stageuid11}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid22}

# ...... LOS Lead As Draft For KYC Stage ...........

    ${resp}=    Save LOS Lead As Draft For Kyc  ${lead_uid}  ${stageuid22}  lead=${lead}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# ...... Save And Proceed LOS Lead KYC ...........

    ${resp}=    Save And Proceed LOS Lead Kyc  ${lead_uid}  ${stageuid22}  lead=${lead}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid33}

# ...... LOS Lead Verify Kyc ...........

    ${resp}=    Verift Los Lead Kyc   ${lead_uid}  ${stageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid44}

# ...... LOS Lead As Draft For salesfield Stage ...........

    ${resp}=    Save LOS Lead As Draft For SALESFIELD  ${lead_uid}  ${stageuid44}  lead=${lead}   remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

# ...... Save And Proceed LOS Lead salesfield ...........

    ${resp}=    Save And Proceed LOS Lead SALESFIELD  ${lead_uid}  ${stageuid44}  lead=${lead}   remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid44}