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

@{sort_order}       1  2  3  4  5  6  7  8  9  10
${aadhaar}          555555555555
${pan}              5555555555
${bankAccountNo}    55555555555
${bankIfsc}         55555555555
${jpgfile}          /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}         0.00458
${order}            0

*** Test Cases ***

JD-TC-GetFinancialSubCategoryEnum-1

    [Documentation]  Get Financial Sub category Enum

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pdrname}   ${decrypted_data['userName']}
    Set Test Variable  ${pid}       ${decrypted_data['id']}

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

    ${resp}=  Enable Disable Branch  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

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

    ${Sname11}=    FakerLibrary.name

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
    Set Suite Variable  ${Sname33}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[3]}  ${Sname33}  sortOrder=${sort_order[2]}  onRedirect=${stageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid33}     ${resp.json()['uid']}

    ${Sname44}=    FakerLibrary.name
    Set Suite Variable  ${Sname44}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[4]}  ${Sname44}  sortOrder=${sort_order[3]}  onRedirect=${stageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid44}     ${resp.json()['uid']}

    ${Sname55}=    FakerLibrary.name
    Set Suite Variable  ${Sname55}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[5]}  ${Sname55}  sortOrder=${sort_order[4]}  onRedirect=${stageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid55}     ${resp.json()['uid']}

    ${Sname66}=    FakerLibrary.name
    Set Suite Variable  ${Sname66}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[6]}  ${Sname66}  sortOrder=${sort_order[5]}  onRedirect=${stageuid55}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid66}     ${resp.json()['uid']}

    ${Sname77}=    FakerLibrary.name
    Set Suite Variable  ${Sname77}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[7]}  ${Sname77}  sortOrder=${sort_order[6]}  onRedirect=${stageuid66}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid77}     ${resp.json()['uid']}

    ${Sname88}=    FakerLibrary.name
    Set Suite Variable  ${Sname88}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[8]}  ${Sname88}  sortOrder=${sort_order[7]}  onRedirect=${stageuid77}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid88}     ${resp.json()['uid']}

    ${Sname99}=    FakerLibrary.name
    Set Suite Variable  ${Sname99}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[9]}  ${Sname99}  sortOrder=${sort_order[8]}  onRedirect=${stageuid88}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid99}     ${resp.json()['uid']}

    ${Sname100}=    FakerLibrary.name
    Set Suite Variable  ${Sname100}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[10]}  ${Sname100}  sortOrder=${sort_order[9]}  onRedirect=${stageuid99}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid100}     ${resp.json()['uid']}



    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[0]}  ${stageuid11}  ${Sname11}  onProceed=${stageuid22}
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

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[2]}  ${stageuid33}  ${Sname33}  onProceed=${stageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid33} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid44}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[3]}  ${stageuid44}  ${Sname44}  onProceed=${stageuid55}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid44} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid55}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid33}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[4]}  ${stageuid55}  ${Sname55}  onProceed=${stageuid66}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid55} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid66}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid44}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[5]}  ${stageuid66}  ${Sname66}  onProceed=${stageuid77}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid66} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid77}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid55}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[6]}  ${stageuid77}  ${Sname77}  onProceed=${stageuid88}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid77} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid88}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid66}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[7]}  ${stageuid88}  ${Sname88}  onProceed=${stageuid99}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid88} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid99}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid77}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${stageType[8]}  ${stageuid99}  ${Sname99}  onProceed=${stageuid100}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${stageuid99} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${stageuid100}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${stageuid88}



    ${resp}=    Get Los Stage
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    Set Suite Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}

    ${requestedAmount}=     Random Int  min=30000  max=600000
    ${description}=         FakerLibrary.bs
    ${permanentAddress2}=   FakerLibrary.address  
    ${nomineeName}=     FakerLibrary.first_name
    ${cdl_status}=  Create Dictionary  id=${status_id}  name=${Sname}
    ${progress}=  Create Dictionary  id=${progress_id}  name=${Pname}
    ${product}=  Create Dictionary  uid=${productuid}
    ${sourcingChannel}=  Create Dictionary  uid=${sourcinguid} 

    ${consumerKyc}=   Create Dictionary  consumerId=${consumerId}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}  consumerEmail=${consumerEmail}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${requestedAmount}  ${branchid1}   product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lead_uid}     ${resp.json()['uid']}
    Set Suite variable  ${lead}         ${resp.json()}

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${PH_Number2}    Random Number 	       digits=5 
    ${PH_Number2}=    Evaluate    f'{${PH_Number2}:0>7d}'
    Log  ${PH_Number2}
    Set Suite Variable    ${Co_Applicant_Phone}  555${PH_Number2}
    ${CO_Applicant_FirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${CO_Applicant_FirstName}
    ${CO_Applicant_LastName}=    FakerLibrary.last_name  
    Set Suite Variable  ${CO_Applicant_LastName}

    ${leadStage}=   Create Dictionary   uid=${stageuid11}
    Set Suite Variable  ${leadStage}
    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}
    ${lead}=    Create Dictionary  product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  requestedAmount=${requestedAmount}  description=${description}  consumerKyc=${consumerKyc}
    Set Suite Variable  ${lead}

    ${resp}=    LOS Lead As Draft For Followup Stage  ${lead_uid}  ${stageuid11}  remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Lead Followup  ${lead_uid}  ${stageuid11}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid22}

    ${resp}=    Generate OTP For LOS Lead Consumer Kyc Phone Number  ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Verify OTP For LOS Lead Consumer Kyc Phone Number  ${consumerPhone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Suite Variable  ${kyc_id}   ${resp.json()['id']}
    
    ${resp}=    Generate OTP For LOS Lead Consumer Kyc Email  ${kyc_id}  ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Verify OTP For LOS Lead Consumer Kyc Email  ${consumerEmail}  ${OtpPurpose['ConsumerVerifyEmail']}  ${kyc_id}  ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

# ..... Co-Applicant KYC .........

    ${resp}=    Generate OTP For LOS Lead Kyc Phone Number  ${lead_uid}  consumerFirstName=${CO_Applicant_FirstName}  consumerLastName=${CO_Applicant_LastName}  consumerPhoneCode=${countryCodes[0]}  consumerPhone=${Co_Applicant_Phone}  gender=${Genderlist[0]}  dob=${dob}  relationType=${relationType[3]}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Verify OTP For LOS Lead Kyc Phone Number  ${Co_Applicant_Phone}  ${OtpPurpose['CoApplicantVerifyPhone']}  ${lead_uid}  consumerFirstName=${CO_Applicant_FirstName}  consumerLastName=${CO_Applicant_LastName}  consumerPhoneCode=${countryCodes[0]}  consumerPhone=${Co_Applicant_Phone}  gender=${Genderlist[0]}  dob=${dob}  relationType=${relationType[3]}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Set Suite Variable  ${CO_Applicant_kyc_id}   ${resp.json()['id']}

    Set Suite Variable  ${CO_email}  ${CO_Applicant_LastName}${Co_Applicant_Phone}.${test_mail}
    
    ${resp}=    Generate OTP For LOS Lead Kyc Email  ${CO_Applicant_kyc_id}  ${lead_uid}  ${CO_email}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Verify OTP For LOS Lead Kyc Email  ${CO_email}  ${OtpPurpose['CoApplicantVerifyEmail']}  ${CO_Applicant_kyc_id}  ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    # .... Verify aadhar and Attachments ......

    ${resp}=            db.getType  ${jpgfile} 
    Log  ${resp}
    ${fileType}=                    Get From Dictionary       ${resp}    ${jpgfile} 
    Set Test Variable              ${fileType}
    ${caption}=                     Fakerlibrary.Sentence
    Set Test Variable              ${caption}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 
    Set Test Variable              ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${attachments}=    Create Dictionary   action=${file_action[0]}  fileName=${jpgfile}  fileSize=${fileSize}  fileType=${fileType}  order=${order}    driveId=${driveId}
    Log  ${attachments}
    ${attachments}=  Create List    ${attachments}
    Set Test Variable              ${attachments}

    ${resp}=    Verify AADHAAR For LOS Lead Kyc  ${idTypes[2]}  ${kyc_id}  ${lead_uid}  ${aadhaar}  ${attachments}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    # .... Verify Pan and Attachments ......

    ${resp}=            db.getType  ${pngfile} 
    Log  ${resp}
    ${fileType2}=                    Get From Dictionary       ${resp}    ${pngfile} 
    Set Test Variable              ${fileType2}
    ${caption2}=                     Fakerlibrary.Sentence
    Set Test Variable              ${caption2}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${pngfile}    ${fileSize}    ${caption2}    ${fileType2}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 
    Set Test Variable              ${driveId2}    ${resp.json()[0]['driveId']}

    ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId2}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${attachments2}=    Create Dictionary   action=${file_action[0]}  fileName=${pngfile}  fileSize=${fileSize}  fileType=${fileType2}  order=${order}    driveId=${driveId2}
    Log  ${attachments2}
    ${attachments2}=  Create List    ${attachments2}
    Set Test Variable              ${attachments2}

    ${resp}=    Verify PAN For LOS Lead Kyc  ${idTypes[6]}  ${kyc_id}  ${lead_uid}  ${pan}  ${attachments2}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200


    ${Co_Applicant_Kyc}=   Create Dictionary  id=${CO_Applicant_kyc_id}  leadUid=${lead_uid}  isCoApplicant=${boolean[1]}  currentAddress1=${permanentAddress1}
    
    ${consumerKyc}=     Create Dictionary  id=${kyc_id}  leadUid=${lead_uid}  isCoApplicant=${boolean[1]}  currentAddress1=${permanentAddress1}

    ${resp}=    Save LOS Lead As Draft For Kyc  ${lead_uid}  ${stageuid22}  ${description}  ${consumerKyc}  ${Co_Applicant_Kyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Lead Kyc  ${lead_uid}  ${stageuid22}  ${description}  ${consumerKyc}  ${Co_Applicant_Kyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid33}

    ${resp}=    Verift Los Lead Kyc   ${lead_uid}  ${stageuid33}  remarks=${description}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid44}

    ${city}=   FakerLibrary.state

    ${resp}=    Save LOS Lead As Draft For SALESFIELD  ${lead_uid}  ${stageuid44}  ${originFrom[6]}  ${city} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Lead SALESFIELD  ${lead_uid}  ${stageuid44}  ${originFrom[6]}  ${city} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    GET LOS Lead Sales Field  ${lead_uid}  ${stageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid55}

    ${resp}=    Save And Proceed LOS Lead Sales Field Verification  ${lead_uid}  ${stageuid55}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid66}

    ${resp}=    Save As Draft LOS Document Data  ${lead_uid}  ${stageuid66}  ${originFrom[6]}  applicationForm=${attachments} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Document Data  ${lead_uid}  ${stageuid66}  ${originFrom[6]}  applicationForm=${attachments} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${stageuid77}

    ${resp1}=    Get Financial Sub category Enum
    Log  ${resp1.content}
    Should Be Equal As Strings      ${resp1.status_code}   200