*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Variables ***

@{emptylist}
${invoiceAmount}    80000
${downpaymentAmount}    20000
${requestedAmount}    60000
${sanctionedAmount}   60000

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458

${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       555553

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       555558

${monthlyIncome}    80000
${emiPaidAmountMonthly}    2000
${start}   12

${customerEducation}  1    
${customerEmployement}   1   
${salaryRouting}    1
${familyDependants}    1
${noOfYearsAtPresentAddress}    1  
${currentResidenceOwnershipStatus}    1 
${ownedMovableAssets}    1
${goodsFinanced}    1
${earningMembers}    1
${existingCustomer}    1
${vehicleNo}    2456
${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000
*** Keywords ***

Account with Multiple Users in NBFC


    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    ${licid}  ${licname}=  get_highest_license_pkg
    
    FOR   ${a}  ${start}   IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        # Set Test Variable  ${pkgId}  ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        # Set Test Variable  ${Dom}   ${resp.json()['sector']}
        # Set Test Variable  ${SubDom}   ${resp.json()['subSector']}
        # ${name}=  Set Variable  ${resp.json()['accountLicenseDetails']['accountLicense']['name']}
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${pkgId}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        Set Test Variable  ${Dom}  ${decrypted_data['sector']}
        Set Test Variable  ${SubDom}  ${decrypted_data['subSector']}
        ${name}=  Set Variable  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

        Continue For Loop If  '${Dom}' != "finance"
        Continue For Loop If  '${SubDom}' != "nbfc"
        Continue For Loop If  '${pkgId}' != '${licId}'

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  '${pkgId}' == '${licId}' and ${resp.json()['metricUsageInfo'][8]['total']} > 2 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
    Exit For Loop
        END
    END
   
    RETURN  ${MUSERNAME${a}}

Loan Application Branchapproval

    [Arguments]    ${loanApplicationUid}    ${note}

    ${data}=  Create Dictionary    note=${note}
    ${data}=  json.dumps  ${data}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw   /provider/loanapplication/${loanApplicationUid}/branchapproval    data=${data}    expected_status=any
    RETURN  ${resp}

Create and Update Account level cdl setting

    [Arguments]    ${autoApproval}    ${autoApprovalUptoAmount}    ${districtWiseRestriction}    ${status}    ${downpaymentRequired}    ${downpaymentRate}
    ...    ${salesOfficerVerificationRequired}    ${branchManagerverificationRequired}     &{kwargs}
    ${data}=  Create Dictionary    autoApproval=${autoApproval}    autoApprovalUptoAmount=${autoApprovalUptoAmount}    districtWiseRestriction=${districtWiseRestriction}    status=${status}
    ...    downpaymentRequired=${downpaymentRequired}    downpaymentRate=${downpaymentRate}    salesOfficerVerificationRequired=${salesOfficerVerificationRequired}    branchManagerverificationRequired=${branchManagerverificationRequired}   
    FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
    END
    
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=    POST On Session    ynw     /provider/cdlsetting/account   data=${data}   expected_status=any 
    RETURN  ${resp}

Generate Otp for co-applicant Phone

    [Arguments]    ${originUid}  ${coApplicantType}   ${customerFirstName}  ${customerLastName}  ${customerPhoneCode}  ${customerPhone}   ${dob}  

    ${data}=    Create Dictionary   originUid=${originUid}  coApplicantType=${coApplicantType}    customerFirstName=${customerFirstName}  customerLastName=${customerLastName}   customerPhoneCode=${customerPhoneCode}  customerPhone=${customerPhone}   dob=${dob}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/generate/coapplicant/phoneotp  data=${data}  expected_status=any
    RETURN  ${resp}

Verify Otp for co-applicant Phone

    [Arguments]    ${originUid}  ${coApplicantType}   ${customerFirstName}  ${customerLastName}  ${customerPhoneCode}  ${customerPhone}     ${purpose}   ${dob}  

    ${otp}=   verify accnt  ${customerPhone}  ${purpose}
    ${data}=    Create Dictionary   originUid=${originUid}  coApplicantType=${coApplicantType}    customerFirstName=${customerFirstName}  customerLastName=${customerLastName}   customerPhoneCode=${customerPhoneCode}  customerPhone=${customerPhone}   dob=${dob}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/verify/coapplicant/${otp}/phoneotp  data=${data}  expected_status=any
    RETURN  ${resp}

Generate Otp for co-applicant Email

    [Arguments]    ${id}  ${originUid}   ${customerEmail}  

    ${data}=    Create Dictionary   id=${id}  originUid=${originUid}    customerEmail=${customerEmail}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/generate/coapplicant/emailotp  data=${data}  expected_status=any
    RETURN  ${resp}

Verify Otp for co-applicant Email

    [Arguments]    ${id}  ${originUid}   ${customerEmail}   ${purpose}

    ${otp}=   verify accnt  ${customerEmail}  ${purpose}
    ${data}=    Create Dictionary   id=${id}  originUid=${originUid}    customerEmail=${customerEmail}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/verify/coapplicant/${otp}/emailotp     data=${data}  expected_status=any
    RETURN  ${resp}

Update CoApplicant Aadhaar

    [Arguments]      ${id}  ${loanApplicationUid}   ${aadhaar}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${aadhaarAttachmentsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${aadhaarAttachmentsList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   originUid=${loanApplicationUid}    aadhaar=${aadhaar}   aadhaarAttachments=${aadhaarAttachmentsList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/updatekyc/document/UID  data=${loan}  expected_status=any
    RETURN  ${resp}

Update CoApplicant Pan

    [Arguments]      ${id}  ${loanApplicationUid}   ${pan}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${panAttachmentsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${panAttachmentsList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   originUid=${loanApplicationUid}    pan=${Pan}   panAttachments=${panAttachmentsList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /provider/loanapplication/updatekyc/document/Pan  data=${loan}  expected_status=any
    RETURN  ${resp}

Update CoApplicant Details
    [Arguments]    ${id}  ${originUid}   ${customerFirstName}  ${customerLastName}  ${customerPhoneCode}  ${customerPhone}    ${dob}   ${gender}   ${maritalStatus}
    ...  ${currentAddress1}  ${currentAddress2}   ${currentPin}  ${currentCity}  ${currentDistrict}  ${currentState}    ${bankName}   ${bankAccountNo}   ${bankIfsc}   ${bankBranchName}
    ...  ${permanentAddress1}   ${permanentAddress2}    ${permanentPin}  ${permanentCity}  ${permanentDistrict}  ${permanentState}    
    

    ${data}=    Create Dictionary   id=${id}  originUid=${originUid}    customerFirstName=${customerFirstName}  customerLastName=${customerLastName}   customerPhoneCode=${customerPhoneCode}  customerPhone=${customerPhone}   dob=${dob}    gender=${gender}  maritalStatus=${maritalStatus}   currentAddress1=${currentAddress1} 
    ...  currentAddress2=${currentAddress2}  currentPin=${currentPin}    currentCity=${currentCity}  currentDistrict=${currentDistrict}   currentState=${currentState}  bankName=${bankName}   bankAccountNo=${bankAccountNo}    bankIfsc=${bankIfsc}  bankBranchName=${bankBranchName} 
    ...   permanentAddress1=${permanentAddress1}   permanentAddress2=${permanentAddress2}    permanentPin=${permanentPin}    permanentCity=${permanentCity}   permanentDistrict=${permanentDistrict}   permanentState=${permanentState}
    ${data}=    Create List  ${data}
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw   /provider/loanapplication/${originUid}/updatekyc  data=${data}  expected_status=any
    RETURN  ${resp}

Delete CoApplicant Details
    [Arguments]    ${loanApplicationUid}  ${kycId}

    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   /provider/loanapplication/${loanApplicationUid}/kyc/${kycId}    expected_status=any
    RETURN  ${resp}

Update Attachments

    [Arguments]      ${id}  ${loanApplicationUid}   ${pan}      @{vargs}
    

    ${len}=  Get Length  ${vargs}
    ${panAttachmentsList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${panAttachmentsList}  ${vargs[${index}]}
    END

    ${loan}=  Create Dictionary    id=${id}   originUid=${loanApplicationUid}    pan=${Pan}   panAttachments=${panAttachmentsList}
    ${loan}=  json.dumps  ${loan}

    Check And Create YNW Session
    ${resp}=  PUT On Session  ynw  /loanapplication/${loanApplicationUid}/kyc/${kycId}/attachments  data=${loan}  expected_status=any
    RETURN  ${resp}

*** Test Cases ***

JD-TC-MafilWorkflow-1

    [Documentation]  Login to a multi account provider, enable rbac and create users.

    # ${NBFCMUSERNAME1}=  Account with Multiple Users in NBFC
    # Log  ${NBFCMUSERNAME1}
    # Set Suite Variable  ${NBFCMUSERNAME1}

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${length}=  Get Length  ${resp.json()}
    FOR   ${domindex}  IN RANGE   ${length}
        IF  "${resp.json()[${domindex}]['domain']}" == "finance"
            ${sublen}=  Get Length  ${resp.json()[${domindex}]['subDomains']}
            FOR   ${subdomindex}  IN RANGE   ${sublen}
                IF  "${resp.json()[${domindex}]['subDomains'][${subdomindex}]['subDomain']}" == "nbfc"
                    Set Test Variable  ${domains}  ${resp.json()[${domindex}]['domain']}
                    Set Test Variable  ${sub_domains}  ${resp.json()[${domindex}]['subDomains'][${subdomindex}]['subDomain']}
                    
                    Exit For Loop
                END
            END
        END
    END
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}

    ${NBFCMUSERNAME1}=  Evaluate  ${MUSERNAME}+8745922
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${NBFCMUSERNAME1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${NBFCMUSERNAME1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${NBFCMUSERNAME1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        # IF   not '${user_phone}' == '${NBFCMUSERNAME1}'
        #     clear_users  ${user_phone}
        # END
    END

    reset_user_metric  ${account_id1}

    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${se_id1}=  Create Sample User 
    Set Suite Variable  ${se_id1}

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SEUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

    ${boh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bm_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BMUSERNAME1}  ${resp.json()['mobileNo']}

    ${sh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}


# ....User 1 :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id}     partners=${partners}
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s
    ${resp}=  Get User By Id  ${provider_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}


# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        Set Suite Variable  ${address1}  ${resp.json()['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
        Set Suite Variable  ${address1}  ${resp.json()[0]['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
    END

    ${locid1}=   Create Sample Location
    Set Suite Variable   ${locid1}

    ${resp}=   Get Location ById  ${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname1}  ${resp.json()['place']}
    
# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${so_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User  :Sales Executive...

    ${role1}=  Create Dictionary   id=${role_id6}  roleName=${role_name6}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${se_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability6}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id6}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name6}


# ....User  :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bch_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability5}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id5}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name5}



# ....User  :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    partners=${partners}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}



# ....User  :Branch Manager...

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bm_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id3}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name3}



# ....User  :Sales Head...

    ${role1}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${sh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# .....Create Dealer By Sales Officer.......

    ${resp}=  SendProviderResetMail   ${SOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}

    ${resp}=    Get Partner Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pcategoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Pcategoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Ptypeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Ptypename}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application ProductCategory
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductcatid}  ${resp.json()[0]['id']}
    
    ${s_len}=  Get Length  ${resp.json()}
    @{loanproductcatid}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${loanproductcatid}  ${resp.json()[${i}]['id']}
    END

    Log  ${loanproductcatid}

    ${resp}=  LoanProductSubCategory    ${account_id1}    @{loanproductcatid}

    ${resp}=    Get Loan Application ProductSubCategory   ${loanproductcatid[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductSubcatid}  ${resp.json()[0]['id']}
   
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}

    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']} 

# <<<--------------------update partner ------------------------------------------------------->>>
    ${partnerName}                FakerLibrary.name
    ${partnerAliasName}           FakerLibrary.name
    ${description}                FakerLibrary.sentence

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    
    Set Test Variable  ${email}  ${phone}.${partnerName}.${test_mail}

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}

    ${resp}=  db.getType   ${jpgfile2}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary       ${resp}    ${jpgfile2}
    Set Suite Variable    ${fileType4}
    ${caption4}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption4}

    ${resp}=  db.getType   ${gif}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${gif}
    Set Suite Variable    ${fileType5}
    ${caption5}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption5}

    ${resp}=  db.getType   ${xlsx}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${xlsx}
    Set Suite Variable    ${fileType6}
    ${caption6}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption6}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid1}    ${partuid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid1}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Approve Dealer By Branch Operation Head......

    
    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    # ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${soid1}  ${resp.json()['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    Set Suite Variable    ${email}  ${firstname_A}${C_Email}.${test_mail}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${Custfname}=  FakerLibrary.name
        Set Suite Variable  ${Custfname} 
        ${Custlname}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname} 
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob} 

        ${resp}=  db.getType   ${pdffile} 
        Log  ${resp}
        ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
        # Set Suite Variable    ${fileType}
        ${caption}=  Fakerlibrary.Sentence

        ${resp}    upload file to temporary location    ${file_action[0]}    ${soid1}    ${ownerType[0]}    ${Custfname}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200 
        Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

        ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200

        ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${soid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
        Log  ${CustomerPhoto}
        # ${CustomerPhoto}=    Create List    ${CustomerPhoto}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${consumernumber}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  SendProviderResetMail   ${BCHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${note}=      FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Avaliable Scheme    ${loanuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${sch1}    ${resp.json()[0]['id']}
    Set Suite Variable    ${minDuration}    ${resp.json()[0]['minDuration']}
    Set Suite Variable    ${maxDuration}    ${resp.json()[0]['maxDuration']}

    ${tenu1}=    Random Int  min=${minDuration}   max=${maxDuration}
    Set Suite Variable    ${tenu1}
    ${tenu}=    Evaluate   ${tenu1} - 1
    ${noOfAdvanceEmi}=    Random Int  min=0   max=${tenu} 
    Set Suite Variable    ${noOfAdvanceEmi}
    ${dayofmonth}=    Random Int  min=1   max=20
    Set Suite Variable    ${dayofmonth}

    ${resp}=  salesofficer Approval    ${loanuid}    ${sch1}     ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}    partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${note}=      FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=  SendProviderResetMail   ${BMUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BMUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BMUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Loan Application Branchapproval  ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[6]}

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}

JD-TC-MafilWorkflow-2

    [Documentation]  Create loan With Partner MafilWorkflow.


    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Identify Partner    ${phone}    ${account_id1}    ${provider_id1}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Verify Otp For Login Partner    ${phone}  12
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Partner Login    ${phone}    ${account_id1}    ${token}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    # ${PH_Number}    Random Number 	digits=5 
    # ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    # Log  ${PH_Number}
    # Set Suite Variable  ${custphone}  555${PH_Number}

    # ${resp}=  GetCustomer  phoneNo-eq=${custphone}  
    # Log  ${resp.content}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable  ${gender} 

    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    
    ${resp}=    Partner Verify Otp for phone   ${consumernumber}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${Custfname}    ${Custlname}    ${consumernumber}    ${countryCodes[0]}    ${locId}    ${kyc_list1}    gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Partner Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Partner loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

    ${resp}=    Verify Partner loan Bank   ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${nomineeName}    FakerLibrary.name
    ${guarantorName}    FakerLibrary.name
    ${partner}=       Create Dictionary    id=${partid1} 
    ${category}=       Create Dictionary    id=${categoryid}  
    ${type}=           Create Dictionary    id=${typeid} 

    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}
    ${employeeCode}=    FakerLibrary.Random Number

    ${montlyIncome}    FakerLibrary.Random Number
    ${nomineedob}=  FakerLibrary.Date
    Set Suite Variable  ${nomineedob}

    ${LoanApplicationKycList}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${phone}  customerEducation=${customerEducation}  customerEmployement=${customerEmployement}  salaryRouting=${salaryRouting}  familyDependants=${familyDependants}  earningMembers=${earningMembers}  existingCustomer=${existingCustomer}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus}  ownedMovableAssets=${ownedMovableAssets}  vehicleNo=${vehicleNo}  goodsFinanced=${goodsFinanced}  guarantorName=${guarantorName}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Approval Loan Application    ${loanuid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Encrypted Provider Login   ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    Set Suite Variable    ${loanProduct} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${sanctionedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid1}    ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}   partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}

JD-TC-MafilWorkflow-3

    [Documentation]  Login to a multi account provider, enable rbac and create users With Roles And Scope.

    ${NBFCMUSERNAME1}=  Account with Multiple Users in NBFC
    Log  ${NBFCMUSERNAME1}
    Set Suite Variable  ${NBFCMUSERNAME1}
    
    ${resp}=  Encrypted Provider Login  ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        # IF   not '${user_phone}' == '${NBFCMUSERNAME1}'
        #     clear_users  ${user_phone}
        # END
    END

    reset_user_metric  ${account_id1}

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable   ${USERNAME1}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME2}=  Evaluate  ${USERNAME1}+${PO_Number}
    Set Suite Variable   ${USERNAME2}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME3}=  Evaluate  ${USERNAME2}+${PO_Number}
    Set Suite Variable   ${USERNAME3}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME4}=  Evaluate  ${USERNAME3}+${PO_Number}
    Set Suite Variable   ${USERNAME4}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME5}=  Evaluate  ${USERNAME4}+${PO_Number}
    Set Suite Variable   ${USERNAME5}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME6}=  Evaluate  ${USERNAME5}+${PO_Number}
    Set Suite Variable   ${USERNAME6}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob1}=  Convert To String  ${dob1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355
# ....User 1 :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all
    ${partner}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id}   partner=${partner}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}    defaultRole=${bool[1]}   scope=${user_scope}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bh_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}
    
    ${resp}=  SendProviderResetMail   ${BHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        Set Suite Variable  ${address1}  ${resp.json()['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
        Set Suite Variable  ${address1}  ${resp.json()['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
    END

    ${locid1}=   Create Sample Location
    Set Suite Variable   ${locid1}

    ${resp}=   Get Location ById  ${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname1}  ${resp.json()['place']}

# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}      scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME2}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${so_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME3}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bch_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Branch Operation Head...

    ${location_id}=  Create List    ${locId}  
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    partners=${partners}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}      scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}
    

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME4}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${boh_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



# .....Create Dealer By Sales Officer.......

    ${resp}=  SendProviderResetMail   ${SOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}
   
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']} 

# <<<--------------------update partner ------------------------------------------------------->>>
    ${partnerName}                FakerLibrary.name
    ${partnerAliasName}           FakerLibrary.name
    ${description}                FakerLibrary.sentence
    # ${aadhaar}    Random Number 	digits=5 
    # ${aadhaar}=    Evaluate    f'{${aadhaar}:0>7d}'
    # Log  ${aadhaar}
    # Set Suite Variable  ${aadhaar}  55555${aadhaar}
    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    
    Set Test Variable  ${email}  ${phone}.${partnerName}.${test_mail}

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid1}    ${partuid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid1}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Approve Dealer By Branch Operation Head......

    
    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    Set Suite Variable    ${email}  ${firstname_A}${C_Email}.${test_mail}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${Custfname}=  FakerLibrary.name
        Set Suite Variable  ${Custfname} 
        ${Custlname}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname} 
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}

        ${resp}=  db.getType   ${pdffile} 
        Log  ${resp}
        ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
        Set Suite Variable    ${fileType}
        ${caption}=  Fakerlibrary.Sentence

        ${resp}    upload file to temporary location    ${file_action[0]}    ${so_id1}    ${ownerType[0]}    ${Custfname}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200 
        Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

        ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200

        ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${so_id1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
        Log  ${CustomerPhoto}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${consumernumber}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  SendProviderResetMail   ${BCHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid1}    ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}    partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}

JD-TC-MafilWorkflow-4

    [Documentation]  Login to a multi account provider, Disable rbac and create users With Roles And Scope.

    ${NBFCMUSERNAME1}=  Account with Multiple Users in NBFC
    Log  ${NBFCMUSERNAME1}
    Set Suite Variable  ${NBFCMUSERNAME1}
    
    ${resp}=  Encrypted Provider Login  ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        # IF   not '${user_phone}' == '${NBFCMUSERNAME1}'
        #     clear_users  ${user_phone}
        # END
    END

    reset_user_metric  ${account_id1}

    ${PO_Number}    Generate random string    5    123456789
    ${USERNAME1}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable   ${USERNAME1}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME2}=  Evaluate  ${USERNAME1}+${PO_Number}
    Set Suite Variable   ${USERNAME2}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME3}=  Evaluate  ${USERNAME2}+${PO_Number}
    Set Suite Variable   ${USERNAME3}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME4}=  Evaluate  ${USERNAME3}+${PO_Number}
    Set Suite Variable   ${USERNAME4}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME5}=  Evaluate  ${USERNAME4}+${PO_Number}
    Set Suite Variable   ${USERNAME5}
    ${PO_Number}    Generate random string    5    123456789

    ${USERNAME6}=  Evaluate  ${USERNAME5}+${PO_Number}
    Set Suite Variable   ${USERNAME6}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob1}=  Convert To String  ${dob1}
    FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    


    ${whpnum}=  Evaluate  ${USERNAME1}+350245
    ${tlgnum}=  Evaluate  ${USERNAME1}+356355
# ....User 1 :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all
    ${partner}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id}   partner=${partner}

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}    defaultRole=${bool[1]}   scope=${user_scope}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME1}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bh_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}
    
    ${resp}=  SendProviderResetMail   ${BHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${locid1}=   Create Sample Location
    Set Suite Variable   ${locid1}

    ${resp}=   Get Location ById  ${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname1}  ${resp.json()['place']}

# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    
# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}      scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME2}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${so_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME3}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bch_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Branch Operation Head...

    ${location_id}=  Create List    ${locId}  
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    partners=${partners}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}      scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}
    

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${USERNAME4}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${USERNAME4}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${boh_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



# .....Create Dealer By Sales Officer.......

    ${resp}=  SendProviderResetMail   ${SOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}
    Set Suite Variable  ${Schemeid3}  ${resp.json()[3]['id']}
    Set Suite Variable  ${Schemename3}  ${resp.json()[3]['schemeName']}
   
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Approve Dealer By Branch Operation Head......

    
    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    Set Suite Variable    ${email}  ${firstname_A}${C_Email}.${test_mail}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${Custfname}=  FakerLibrary.name
        Set Suite Variable  ${Custfname} 
        ${Custlname}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname} 
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}

        ${resp}=  db.getType   ${pdffile} 
        Log  ${resp}
        ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
        Set Suite Variable    ${fileType}
        ${caption}=  Fakerlibrary.Sentence

        ${resp}    upload file to temporary location    ${file_action[0]}    ${so_id1}    ${ownerType[0]}    ${Custfname}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200 
        Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

        ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200

        ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${so_id1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
        Log  ${CustomerPhoto}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${consumernumber}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid3}  name=${Schemename3}

    ${partner}=  Create Dictionary  id=${partid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  SendProviderResetMail   ${BCHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid3}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid3}    ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}    partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}


JD-TC-MafilWorkflow-5

    [Documentation]  Login to a multi account provider, create loan appliction with cdl Settings (enable all).

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME22}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get roles
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        # IF   not '${user_phone}' == '${HLMUSERNAME22}'
        #     clear_users  ${user_phone}
        # END
    END

    reset_user_metric  ${account_id1}

    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${se_id1}=  Create Sample User 
    Set Suite Variable  ${se_id1}

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SEUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

    ${boh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bm_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BMUSERNAME1}  ${resp.json()['mobileNo']}

    ${sh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}


# ....User 1 :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id}     partners=${partners}
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s
    ${resp}=  Get User By Id  ${provider_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}


# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
    END

    ${locid1}=   Create Sample Location
    Set Suite Variable   ${locid1}

    ${resp}=   Get Location ById  ${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname1}  ${resp.json()['place']}
    
# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}     
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${so_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User  :Sales Executive...

    ${role1}=  Create Dictionary   id=${role_id6}  roleName=${role_name6}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${se_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability6}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id6}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name6}


# ....User  :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bch_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability5}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id5}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name5}



# ....User  :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    ${partners}=  Create List    all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    partners=${partners}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}



# ....User  :Branch Manager...

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bm_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id3}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name3}



# ....User  :Sales Head...

    ${role1}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${sh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
   
    #Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# .....Create Dealer By Sales Officer.......

    ${resp}=  SendProviderResetMail   ${SOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}
    Set Suite Variable  ${Productid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${productname1}  ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']}

    ${resp}=    Get Loan Application ProductCategory
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductcatid}  ${resp.json()[0]['id']}
    
    ${s_len}=  Get Length  ${resp.json()}
    @{loanproductcatid}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${loanproductcatid}  ${resp.json()[${i}]['id']}
    END

    Log  ${loanproductcatid}

    ${resp}=  LoanProductSubCategory    ${account_id1}    @{loanproductcatid}

    ${resp}=    Get Loan Application ProductSubCategory   ${loanproductcatid[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductSubcatid}  ${resp.json()[0]['id']}
   
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']} 

# <<<--------------------update partner ------------------------------------------------------->>>
    ${partnerName}                FakerLibrary.name
    ${partnerAliasName}           FakerLibrary.name
    ${description}                FakerLibrary.sentence
    # ${aadhaar}    Random Number 	digits=5 
    # ${aadhaar}=    Evaluate    f'{${aadhaar}:0>7d}'
    # Log  ${aadhaar}
    # Set Suite Variable  ${aadhaar}  55555${aadhaar}
    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    
    Set Test Variable  ${email}  ${phone}.${partnerName}.${test_mail}

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid1}    ${partuid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid1}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Approve Dealer By Branch Operation Head......

    
    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    Set Suite Variable    ${email}  ${firstname_A}${C_Email}.${test_mail}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${Custfname}=  FakerLibrary.name
        Set Suite Variable  ${Custfname} 
        ${Custlname}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname} 
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob} 

        ${resp}=  db.getType   ${pdffile} 
        Log  ${resp}
        ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
        Set Suite Variable    ${fileType}
        ${caption}=  Fakerlibrary.Sentence

        ${resp}    upload file to temporary location    ${file_action[0]}    ${so_id1}    ${ownerType[0]}    ${Custfname}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200 
        Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

        ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200

        ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${so_id1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
        Log  ${CustomerPhoto}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${consumernumber}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}

    ${partner}=  Create Dictionary  id=${partid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    ${originFrom[2]}    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  SendProviderResetMail   ${BCHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  salesofficer Approval    ${loanuid}    ${Schemeid}    ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}    partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[5]}

    ${note}=      FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=  SendProviderResetMail   ${BMUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BMUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BMUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Loan Application Branchapproval  ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[6]}

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${BMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   loanDigitalSignUpload      ${cookie}    ${account_id}    ${loanuid}    ${kycid}   DPN   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   loanDigitalSignUpload      ${cookie}    ${account_id}    ${loanuid}    ${kycid}   SPDC   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[7]}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[9]}

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[10]}

JD-TC-MafilWorkflow-5

    [Documentation]  create a loan application and add co-applicant for that loan application.

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    # ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get roles
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}     ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}   ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}  ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}     ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}   ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}  ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}     ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}   ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}  ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}  ${resp.json()[6]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END


# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        # IF   not '${user_phone}' == '${HLMUSERNAME20}'
        #     clear_users  ${user_phone}
        # END
    END

    reset_user_metric  ${account_id1}

    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${se_id1}=  Create Sample User 
    Set Suite Variable  ${se_id1}

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SEUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

    ${boh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bm_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BMUSERNAME1}  ${resp.json()['mobileNo']}

    ${sh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all

    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id} 
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  
    # ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Replace User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  07s
    ${resp}=  Get User By Id  ${provider_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}


# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${locname}  ${resp.json()['place']}
        Set Suite Variable  ${address1}  ${resp.json()['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
        
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${locname}  ${resp.json()[0]['place']}
        Set Suite Variable  ${address1}  ${resp.json()[0]['address']}
        ${address2}    FakerLibrary.Street name
        Set Suite Variable    ${address2}
    END

    ${locid1}=   Create Sample Location
    Set Suite Variable   ${locid1}

    ${resp}=   Get Location ById  ${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname1}  ${resp.json()['place']}
    
# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# .... Create Branch2....

    ${branchCode1}=    FakerLibrary.Random Number
    ${branchName1}=    FakerLibrary.name
    Set Suite Variable  ${branchName1}
   
    ${resp}=    Create BranchMaster    ${branchCode1}    ${branchName1}    ${locId1}    ${status[0]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${so_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User  :Sales Executive...

    ${role1}=  Create Dictionary   id=${role_id6}  roleName=${role_name6}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${se_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${se_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name6}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability6}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id6}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name6}


# ....User  :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bch_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability5}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id5}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name5}



# ....User  :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}



# ....User  :Branch Manager...

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bm_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${bm_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name3}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id3}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name3}



# ....User  :Sales Head...

    ${role1}=  Create Dictionary   id=${role_id2}  roleName=${role_name2}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${sh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # sleep  05s

    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=${bool[0]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}    ${branch2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# .....Create Dealer1 By Sales Officer.......

    ${resp}=  SendProviderResetMail   ${SOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}
    Set Suite Variable  ${categoryid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${categoryname1}  ${resp.json()[1]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}
    Set Suite Variable  ${typeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${typename1}  ${resp.json()[1]['name']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    
    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 

    ${resp}=    Get Loan Application ProductCategory
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductcatid}  ${resp.json()[0]['id']}
    
    ${s_len}=  Get Length  ${resp.json()}
    @{loanproductcatid}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${loanproductcatid}  ${resp.json()[${i}]['id']}
    END

    Log  ${loanproductcatid}

    ${resp}=  LoanProductSubCategory    ${account_id1}    @{loanproductcatid}

    ${resp}=    Get Loan Application ProductSubCategory   ${loanproductcatid[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanproductSubcatid}  ${resp.json()[0]['id']}

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name

    ${resp}=    Get Partner Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pcategoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Pcategoryname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Ptypeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Ptypename}  ${resp.json()[0]['name']}
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob} 
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']} 
# <<<--------------------update partner ------------------------------------------------------->>>
    ${partnerName}                FakerLibrary.name
    ${partnerAliasName}           FakerLibrary.name
    ${description}                FakerLibrary.sentence
    # ${aadhaar}    Random Number 	digits=5 
    # ${aadhaar}=    Evaluate    f'{${aadhaar}:0>7d}'
    # Log  ${aadhaar}
    # Set Suite Variable  ${aadhaar}  55555${aadhaar}
    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}
    ${partnerCity}    FakerLibrary.city
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}

    
    Set Test Variable  ${email}  ${phone}.${partnerName}.${test_mail}

    ${bankAccountNo}    Random Number 	digits=5 
    ${bankAccountNo}=    Evaluate    f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable  ${bankAccountNo}  55555${bankAccountNo}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc}  

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${resp}=  db.getType   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType3}
    ${caption3}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption3}

    ${resp}=  db.getType   ${jpgfile2}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary       ${resp}    ${jpgfile2}
    Set Suite Variable    ${fileType4}
    ${caption4}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption4}

    ${resp}=  db.getType   ${gif}
    Log  ${resp}
    ${fileType5}=  Get From Dictionary       ${resp}    ${gif}
    Set Suite Variable    ${fileType5}
    ${caption5}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption5}

    ${resp}=  db.getType   ${xlsx}
    Log  ${resp}
    ${fileType6}=  Get From Dictionary       ${resp}    ${xlsx}
    Set Suite Variable    ${fileType6}
    ${caption6}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption6}

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid1}    ${partuid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid1}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid1}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    ${firstname_A}=    FakerLibrary.name
    Set Suite Variable    ${email}  ${firstname_A}${C_Email}.${test_mail}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${Custfname}=  FakerLibrary.name
        Set Suite Variable  ${Custfname} 
        ${Custlname}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname} 
        ${gender}    Random Element    ${Genderlist}
        Set Suite Variable  ${gender} 

        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        Set Suite Variable  ${dob}

        ${resp}=  db.getType   ${pdffile} 
        Log  ${resp}
        ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
        Set Suite Variable    ${fileType}
        ${caption}=  Fakerlibrary.Sentence

        ${resp}    upload file to temporary location    ${file_action[0]}    ${so_id1}    ${ownerType[0]}    ${Custfname}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200 
        Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

        ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200

        ${CustomerPhoto}=    Create Dictionary   action=${LoanAction[0]}  owner=${so_id1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}    driveId=${driveId}
        Log  ${CustomerPhoto} 


        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid}     ${loanuid}   ${consumernumber}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state
    ${bankDis}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}    bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# # <----------------------------- Bank Details ------------------------------------------> 
# # <----------------------------- Add co-Applicant ------------------------------------------> 
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${co-phone}  555${PH_Number}

    ${customerFirstName}=  FakerLibrary.name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${customerLastName}=  FakerLibrary.last_name

    ${resp}=  Generate Otp for co-applicant Phone   ${loanuid}   ${NomineeType[6]}  ${customerFirstName}  ${customerLastName}      ${countryCodes[0]}    ${co-phone}   ${dob}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Verify Otp for co-applicant Phone   ${loanuid}   ${NomineeType[6]}  ${customerFirstName}  ${customerLastName}      ${countryCodes[0]}    ${co-phone}  ${OtpPurpose['CoApplicantVerifyPhone']}  ${dob}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    Set Test Variable    ${email}  ${customerLastName}${C_Email}.${test_mail}

    ${resp}=  Generate Otp for co-applicant Email     ${loanid}    ${loanuid}   ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Verify Otp for co-applicant Email    ${loanid}    ${loanuid}   ${email}   ${OtpPurpose['CoApplicantVerifyEmail']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Update CoApplicant Aadhaar    ${loanid}    ${loanuid}   ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Update CoApplicant Pan    ${loanid}    ${loanuid}   ${pan}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Update CoApplicant Details     ${loanid}    ${loanuid}   ${customerFirstName}  ${customerLastName}      ${countryCodes[0]}    ${co-phone}   ${dob}    ${Genderlist[1]}    ${MaritalStatus[1]}   
    ...  ${bankAddress1}    ${bankAddress2}    ${bankPin}  ${bankCity}  ${bankDis}    ${bankState}  ${bankName}   ${bankAccountNo2}    ${bankIfsc}   ${bankName} 
    ...  ${bankAddress1}    ${bankAddress2}    ${bankPin}  ${bankCity}  ${bankDis}    ${bankState}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# # <----------------------------- Add co-Applicant  ------------------------------------------> 

#     ${remark}=    FakerLibrary.sentence
#     ${note}=      FakerLibrary.sentence

#     ${resp}=    LoanApplication Remark        ${loanuid}    ${remark}
#     Log    ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

#     ${resp}=   Add General Notes    ${loanuid}    ${note}
#     Log    ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

#     ${resp}=    Loan Application Approval        ${loanuid}    
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Get Loan Application By uid  ${loanuid} 
#     Log  ${resp.content}
#     Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-MafilWorkflow-6

    [Documentation]  Delete co-applicant 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Loan Application By uid  ${loanuid} 
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200
    # Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    # Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][1]["id"]} 

    
    ${resp}=    Delete CoApplicant Details   ${loanuid}  ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200