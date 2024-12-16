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
${pngfile}          /ebs/TDD/upload.png
${fileSize}         0.00458
${order}            0
${dob}              1996-11-04

*** Test Cases ***

JD-TC-GetLosLeadKyc-1

    [Documentation]  Get Los Lead Kyc

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD} 
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







    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}






    
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


#.......  Creating Lead Stages ............


    ${LeadSname11}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[1]}  ${LeadSname11}  sortOrder=${sort_order[0]}  isDefault=${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Leadstageuid11}     ${resp.json()['uid']}

    ${LeadSname22}=    FakerLibrary.name

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[2]}  ${LeadSname22}  sortOrder=${sort_order[1]}  onRedirect=${Leadstageuid11}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Leadstageuid22}     ${resp.json()['uid']}

    ${LeadSname33}=    FakerLibrary.name
    Set Suite Variable  ${LeadSname33}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[3]}  ${LeadSname33}  sortOrder=${sort_order[2]}  onRedirect=${Leadstageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Leadstageuid33}     ${resp.json()['uid']}

    ${LeadSname44}=    FakerLibrary.name
    Set Suite Variable  ${LeadSname44}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[4]}  ${LeadSname44}  sortOrder=${sort_order[3]}  onRedirect=${Leadstageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Leadstageuid44}     ${resp.json()['uid']}

    ${LeadSname55}=    FakerLibrary.name
    Set Suite Variable  ${LeadSname55}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[5]}  ${LeadSname55}  sortOrder=${sort_order[4]}  onRedirect=${Leadstageuid44}    isFinalStage=${boolean[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Leadstageuid55}     ${resp.json()['uid']}


#........ Update Lead Stages .............


    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[0]}  ${Leadstageuid11}  ${LeadSname11}  onProceed=${Leadstageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Leadstageuid11} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Leadstageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[1]}  ${Leadstageuid22}  ${LeadSname22}  onProceed=${Leadstageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Leadstageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Leadstageuid33}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Leadstageuid11}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[2]}  ${Leadstageuid33}  ${LeadSname33}  onProceed=${Leadstageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Leadstageuid33} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Leadstageuid44}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Leadstageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[3]}  ${Leadstageuid44}  ${LeadSname44}  onProceed=${Leadstageuid55}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Leadstageuid44} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Leadstageuid55}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Leadstageuid33}


#.......  Creating Loan Stages ............


    ${LoanSname11}=    FakerLibrary.name
    Set Suite Variable  ${LoanSname11}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[0]}  ${LoanSname11}  sortOrder=${sort_order[5]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Loanstageuid11}     ${resp.json()['uid']}

    ${LoanSname22}=    FakerLibrary.name
    Set Suite Variable  ${LoanSname22}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[1]}  ${LoanSname22}  sortOrder=${sort_order[6]}  onRedirect=${Loanstageuid11}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Loanstageuid22}     ${resp.json()['uid']}

    ${LoanSname33}=    FakerLibrary.name
    Set Suite Variable  ${LoanSname33}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[2]}  ${LoanSname33}  sortOrder=${sort_order[7]}  onRedirect=${Loanstageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Loanstageuid33}     ${resp.json()['uid']}

    ${LoanSname44}=    FakerLibrary.name
    Set Suite Variable  ${LoanSname44}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[3]}  ${LoanSname44}  sortOrder=${sort_order[8]}  onRedirect=${Loanstageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Loanstageuid44}     ${resp.json()['uid']}

    ${LoanSname55}=    FakerLibrary.name
    Set Suite Variable  ${LoanSname55}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[4]}  ${LoanSname55}  sortOrder=${sort_order[9]}  onRedirect=${Loanstageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${Loanstageuid55}     ${resp.json()['uid']}


#........ Update Loan Stages .............
    

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${leadleadstageType[5]}  ${Loanstageuid11}  ${LoanSname11}  onProceed=${Loanstageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Loanstageuid11} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Loanstageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[0]}  ${Loanstageuid22}  ${LoanSname22}  onProceed=${Loanstageuid33}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Loanstageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Loanstageuid33}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Loanstageuid11}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[1]}  ${Loanstageuid33}  ${LoanSname33}  onProceed=${Loanstageuid44}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Loanstageuid33} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Loanstageuid44}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Loanstageuid22}

    ${resp}=    Update Los Lead Stage  ${losProduct[0]}  ${loanleadstageType[2]}  ${Loanstageuid44}  ${LoanSname44}  onProceed=${Loanstageuid55}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead Stage By UID  ${Loanstageuid44} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()['onProceed']}   ${Loanstageuid55}
    Should Be Equal As Strings    ${resp.json()['onRedirect']}  ${Loanstageuid33}



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
    # ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${consumerKyc}=   Create Dictionary  consumerId=${consumerId}  nomineeType=${nomineeType[2]}  nomineeName=${nomineeName}  consumerEmail=${consumerEmail}  firstName=${consumerFirstName}   lastName=${consumerLastName}

    ${resp}=    Create Lead LOS  ${leadchannel[0]}  ${description}  ${requestedAmount}  ${branchid1}  product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  consumerKyc=${consumerKyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lead_uid}     ${resp.json()['uid']}
    Set Suite variable  ${lead}         ${resp.json()}

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200





    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366968
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346862
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346389

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${userType[0]}    deptId=${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200





    ${PH_Number2}    Random Number 	       digits=5 
    ${PH_Number2}=    Evaluate    f'{${PH_Number2}:0>7d}'
    Log  ${PH_Number2}
    Set Suite Variable    ${Co_Applicant_Phone}  555${PH_Number2}
    ${CO_Applicant_FirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${CO_Applicant_FirstName}
    ${CO_Applicant_LastName}=    FakerLibrary.last_name  
    Set Suite Variable  ${CO_Applicant_LastName}

    ${leadStage}=   Create Dictionary   uid=${Leadstageuid11}
    Set Suite Variable  ${leadStage}
    ${remarks}=    FakerLibrary.name
    Set Suite Variable  ${remarks}
    ${lead}=    Create Dictionary  product=${product}  sourcingChannel=${sourcingChannel}  status=${cdl_status}  progress=${progress}  requestedAmount=${requestedAmount}  description=${description}  consumerKyc=${consumerKyc}
    Set Suite Variable  ${lead}

    ${resp}=    LOS Lead As Draft For Followup Stage  ${lead_uid}  ${Leadstageuid11}  generatedBy=${u_id1}  remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Lead Followup  ${lead_uid}  ${Leadstageuid11}  generatedBy=${u_id1}  remarks=${remarks}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    GET LOS FollowUp Data   ${lead_uid}  ${Leadstageuid11} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Lead LOS   ${lead_uid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200
    Should Be Equal As Strings      ${resp.json()['stage']['uid']}   ${Leadstageuid22}

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

    ${resp}=    Save LOS Lead As Draft For Kyc  ${lead_uid}  ${Leadstageuid22}  ${description}  ${consumerKyc}  ${Co_Applicant_Kyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Save And Proceed LOS Lead Kyc  ${lead_uid}  ${Leadstageuid22}  ${description}  ${consumerKyc}  ${Co_Applicant_Kyc}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    GET LOS Lead KYC  ${lead_uid}  ${Leadstageuid22}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}   200


JD-TC-GetLosLeadKyc-UH1

    [Documentation]  Get Los Lead Kyc - with another provider login 

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME44}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    GET LOS Lead KYC  ${lead_uid}  ${Leadstageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-GetLosLeadKyc-UH2

    [Documentation]  Get Los Lead Kyc - without login 

    ${resp}=    GET LOS Lead KYC  ${lead_uid}  ${Leadstageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-GetLosLeadKyc-UH3

    [Documentation]  Get Los Lead Kyc - where lead uid is invalid

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     Random Int  min=11111  max=999999

    ${resp}=    GET LOS Lead KYC  ${inv}  ${Leadstageuid22} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-GetLosLeadKyc-UH4

    [Documentation]  Get Los Lead Kyc - where stage is invalid

    ${resp}=   Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv}=     Random Int  min=11111  max=999999

    ${resp}=    GET LOS Lead KYC  ${lead_uid}  ${inv} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200