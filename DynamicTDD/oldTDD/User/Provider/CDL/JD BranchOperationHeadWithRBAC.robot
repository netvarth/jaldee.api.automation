*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        RBAC
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ApiKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}
${self}    0

# ${invoiceAmount}    60000
# ${downpaymentAmount}    2000
# ${requestedAmount}    58000
# ${sanctionedAmount}   58000

${invoiceAmount}    22000
${downpaymentAmount}    2000
${requestedAmount}    20000
${sanctionedAmount}   18000


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
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589

${monthlyIncome}    80000
${emiPaidAmountMonthly}    2000

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000


*** Test Cases ***

JD-TC-BranchOperationHead-1

    [Documentation]   Create Branch operation Head(with append role) and Create a partner by sales officer
    ...   then branch operation head - view partner.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

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
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME18}'
                clear_users  ${user_phone}
            END
        END
    END

    reset_user_metric  ${account_id1}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${so_id2}=  Create Sample User 
    Set Suite Variable  ${so_id2}
    
    ${resp}=  Get User By Id  ${so_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME2}  ${resp.json()['mobileNo']}

    ${boh_id1}=  Create Sample User 
    Set Suite Variable  ${boh_id1}
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all

    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id} 
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    
    ${locid2}=   Create Sample Location
    Set Suite Variable   ${locid2}

    ${resp}=   Get Location ById  ${locid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locname2}  ${resp.json()['place']}
    
# .... Create Branch1....

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pin}  ${resp.json()['pinCode']}

    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}

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
   
    ${resp}=    Create BranchMaster    ${branchCode1}    ${branchName1}    ${locid2}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
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

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 2 :Sales Officer2...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1}  
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${so_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${so_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....create sales officer 3 with roles and scope......

    ${PO_Number}    Generate random string    5    123456789
    ${SOUSERNAME3}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable  ${SOUSERNAME3} 
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


    ${whpnum}=  Evaluate  ${SOUSERNAME3}+350245
    ${tlgnum}=  Evaluate  ${SOUSERNAME3}+356355

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${SOUSERNAME3}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${SOUSERNAME3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${so_id3}  ${resp.json()}

# ....User 3 :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}


# ....create branch operation head 2 with roles and scope......

    ${PO_Number}    Generate random string    5    123456789
    ${BOHUSERNAME2}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Set Suite Variable  ${BOHUSERNAME2} 
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


    ${whpnum}=  Evaluate  ${BOHUSERNAME2}+350245
    ${tlgnum}=  Evaluate  ${BOHUSERNAME2}+356355

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}  ${so_id2}

    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  
    ${user_roles}=  Create List   ${role1}

    ${resp}=  Create User With Roles And Scope  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  
    ...   ${P_Email}${BOHUSERNAME2}.${test_mail}   ${userType[0]}  ${pin1}  
    ...   ${countryCodes[0]}  ${BOHUSERNAME2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${boh_id2}  ${resp.json()}

# .....Assigning branches to users

    ${userids}=  Create List  ${so_id1}   ${so_id3}  ${boh_id1}
    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=True

    ${resp}=  Assigning Branches to Users   ${userids}   ${branch1}
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


# .....Create Dealer2 By Sales Officer.......

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone1}  555${PH_Number}
    ${dealerfname2}=  FakerLibrary.name
    ${dealername2}=  FakerLibrary.bs
    ${dealerlname2}=  FakerLibrary.last_name
   
    ${resp}=  Generate Phone Partner Creation    ${phone1}    ${countryCodes[0]}    partnerName=${dealername2}   partnerUserFirstName=${dealerfname2}  partnerUserLastName=${dealerlname2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname1}=  FakerLibrary.name
    ${dealerlname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
   
    ${branch}=      Create Dictionary   id=${branchid2}

    ${resp}=  Verify Phone Partner Creation    ${phone1}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname1}   ${dealerlname1}   branch=${branch}    partnerUserFirstName=${dealerfname2}  partnerUserLastName=${dealerlname2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid2}  ${resp.json()['id']}
    Set Suite Variable  ${partuid2}  ${resp.json()['uid']} 

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

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid2}    ${partuid2}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid2}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid2}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername2}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ......branch operation head view partner.......

    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['partnerName']}   ${partnername1}

JD-TC-BranchOperationHead-2

    [Documentation]  branch operation head -approve partner.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${NO_PERMISSION_FOR_REQUEST}

    # ${resp}=    Get Partner by UID    ${partuid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200 


JD-TC-BranchOperationHead-3

    [Documentation]  branch operation head -try to approve partner who is already approved.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"
    

JD-TC-BranchOperationHead-4

    [Documentation]  disable branch operation head by bussiness head then try to approve partner.
   
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   EnableDisable User   ${boh_id1}    ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}     "${INACTIVE_PROVIDER}"

# ....again activate the user for further cases....

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME18}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   EnableDisable User   ${boh_id1}    ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-BranchOperationHead-5

    [Documentation]  try to approve a partner created by a sales officer who is not in the scope of that branch operation head.

    ${resp}=  SendProviderResetMail   ${BOHUSERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Partner Approved    ${partuid2}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"


JD-TC-BranchOperationHead-6

    [Documentation]  a branch operation head try to approve partner who is approved by another branch operation head in the same account.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"
    # Should Be Equal As Strings  ${resp.content}       "${PARTNER_ALREADY_APPROVED}"
 

JD-TC-BranchOperationHead-7

    [Documentation]   branch operation head- update with same SalesOfficer.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['salesOfficer']['id']}      ${so_id1}
    Should Be Equal As Strings    ${resp.json()['salesOfficers']}  []

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['partnerName']}         ${partnername1}
    Should Be Equal As Strings    ${resp.json()['salesOfficers'][0]['id']}       ${so_id1}
      
JD-TC-BranchOperationHead-8

    [Documentation]   branch operation head- update with another SalesOfficer.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['salesOfficer']['id']}  ${so_id1}
   
    ${Salesofficer}=    Create Dictionary    id=${so_id3}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['partnerName']}         ${partnername1}
    Should Be Equal As Strings    ${resp.json()['salesOfficers'][0]['id']}       ${so_id3}
  
JD-TC-BranchOperationHead-9

    [Documentation]  branch operation head- update Partner Settings(update same credit officer).

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['creditOfficers']}  []

    ${operationhead}=    Create Dictionary    id=${boh_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${operationhead}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['partnerName']}         ${partnername1}
    Should Be Equal As Strings    ${resp.json()['creditOfficers'][0]['id']}    ${boh_id1}

JD-TC-BranchOperationHead-10

    [Documentation]   branch operation head- enable partner.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 


JD-TC-BranchOperationHead-11

    [Documentation]  branch operation head- disable partner.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-BranchOperationHead-12

    [Documentation]   branch operation head- update partner.

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone1}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name

    ${resp}=  Generate Phone Partner Creation    ${phone1}    ${countryCodes[0]}     partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname1}=  FakerLibrary.name
    ${dealerlname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone1}   ${OtpPurpose['ProviderVerifyPhone']}   ${dealerfname1}   ${dealerlname1}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid2}  ${resp.json()['id']}
    Set Suite Variable  ${partuid2}  ${resp.json()['uid']} 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=    Create List  ${panAttachments}

    ${gstAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    ${gstAttachments}=    Create List  ${gstAttachments}

    ${licenceAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=    Create List  ${licenceAttachments}

    ${partnerAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${gif}  fileSize=${fileSize}  caption=${caption5}  fileType=${fileType5}  order=${order}
    ${partnerAttachments}=    Create List  ${partnerAttachments}

    ${storeAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${partid2}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption6}  fileType=${fileType6}  order=${order}
    ${storeAttachments}=    Create List  ${storeAttachments}

    ${resp}    Update Partner Aadhar    ${aadhaar}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Aadhaar Status    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Pan    ${pan}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Update Partner Bank    ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid2}    ${LoanAction[0]}    ${partid2}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Verify Partner Bank    ${partid2}    ${partuid2}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Validate Gst    ${partuid2}     ${gstin}    
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}    Get Partner by UID     ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Details    ${partuid2}    ${partnerName}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner by UID    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# <<<--------------------update partner ------------------------------------------------------->>>

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername2}  ${resp.json()[0]['partnerName']}

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    Set Suite Variable    ${email}  ${dealerfname1}${C_Email}.${test_mail}
    
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

    # ${resp}=  ProviderLogout
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  db.getType   ${jpgfile}
    # Log  ${resp}
    # ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    # ${caption1}=  Fakerlibrary.Sentence
  
    # ${resp}=  db.getType   ${pngfile}
    # Log  ${resp}
    # ${fileType2}=  Get From Dictionary       ${resp}    ${pngfile}
    # ${caption2}=  Fakerlibrary.Sentence
   
    # ${resp}=  db.getType   ${pdffile} 
    # Log  ${resp}
    # ${fileType3}=  Get From Dictionary       ${resp}    ${pdffile} 
    # ${caption3}=  Fakerlibrary.Sentence
   
    # ${nomineeName}        FakerLibrary.name
    # ${permanentAddress1}     FakerLibrary.Street name
    # ${permanentAddress2}     FakerLibrary.Street name
    # ${permanentPin}          Generate random string    6    0123456789
    # ${permanentCity}         FakerLibrary.word
    # ${permanentState}        FakerLibrary.state
    # ${currentAddress1}       FakerLibrary.Street name
    # ${currentAddress2}       FakerLibrary.Street name
    # ${currentPin}            Generate random string    6    0123456789
    # ${currentCity}           FakerLibrary.word
    # ${currentState}          FakerLibrary.state

    # ${otherAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    # ${otherAttachmentsList}=    Create List  ${otherAttachments}

    # ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    # ${panAttachments}=    Create List  ${panAttachments}

    # ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    # ${aadhaarAttachments}=    Create List  ${aadhaarAttachments}

    # ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}  maritalStatus=${maritalStatus[1]}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  aadhaar=${aadhaar}  pan=${pan}  isAadhaarVerified=${bool[1]}  isPanVerified=${bool[1]}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  permanentAddress1=${permanentAddress1}  permanentAddress2=${permanentAddress2}  permanentPin=${permanentPin}  permanentCity=${permanentCity}  permanentState=${permanentState}  currentAddress1=${currentAddress1}  currentAddress2=${currentAddress2}  currentPin=${currentPin}  currentCity=${currentCity}  currentState=${currentState}    otherAttachments=${otherAttachmentsList}  panAttachments=${panAttachments}  aadhaarAttachments=${aadhaarAttachments}
    # Log  ${kyc_list1}
    # Set Suite Variable    ${kyc_list1}

    # ${partnerName}           FakerLibrary.name
    # ${partnerAliasName}      FakerLibrary.name
    # ${description}           FakerLibrary.sentence
    # ${gstin}                 FakerLibrary.Random Number
    # ${partnerAddress1}       FakerLibrary.Street name
    # ${partnerAddress2}       FakerLibrary.Street name
    # ${partnerPin}            Generate random string    6    0123456789
    # ${partnerCity}           FakerLibrary.word
    # ${partnerState}          FakerLibrary.state
    # ${bankName}              FakerLibrary.name
    # ${bankAccountNo}         FakerLibrary.Random Number
    # ${bankIfsc}              FakerLibrary.Random Number
    # ${partnerMobile}              FakerLibrary.Random Number
    # ${description}                FakerLibrary.sentence

    # ${resp}=    Update Partner    ${partuid2}     ${EMPTY}    ${EMPTY}    ${partnerName}     ${partnerAliasName}    ${partnerMobile}    ${EMPTY}    ${description}    ${aadhaar}    ${pan}
    # ...    ${gstin}    ${partnerAddress1}    ${partnerAddress2}    ${partnerPin}    ${partnerCity}    ${partnerState}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${parentSize[1]}    ${partnerTrade[1]}    ${bool[1]}   ${bool[1]}    ${LoanAction[0]}  ${custid}  ${jpgfile}  ${fileSize}  ${caption1}  ${fileType1}  ${order}  ${kyc_list1}     branch=${branch}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200 


    # ${resp}=   Get Partner by UID    ${partuid2} 
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200 


JD-TC-BranchOperationHead-13

    [Documentation]  branch operation head- view LoanApplication.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-BranchOperationHead-14

    [Documentation]   branch operation head- approve LoanApplication.

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}

# <----------------------------- KYC Details ------------------------------------------>

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

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
    ${loanScheme}=     Create Dictionary    id=${Schemeid2}  name=${Schemename2}

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

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid2}  
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

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-BranchOperationHead-15

    [Documentation]  branch operation head- loanApplication Operations Verification.


    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Avaliable Tenures    ${loanid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${tenu1}    ${resp.json()[0]['id']}

    ${resp}=    Get Avaliable Scheme    ${loanuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${sch1}    ${resp.json()[0]['id']}
    Set Suite Variable    ${minDuration}    ${resp.json()[0]['minDuration']}
    Set Suite Variable    ${maxDuration}    ${resp.json()[0]['maxDuration']}

    ${tenu1}=    Random Int  min=${minDuration}   max=${maxDuration}
    ${tenu}=    Evaluate   ${tenu1} - 1
    ${noOfAdvanceEmi}=    Random Int  min=0   max=${tenu} 
    ${dayofmonth}=    Random Int  min=1   max=20

    ${resp}=  salesofficer Approval    ${loanuid}    ${sch1}    ${tenu1}    ${noOfAdvanceEmi}   ${dayofmonth}   partner=${partner}
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


JD-TC-BranchOperationHead-16

    [Documentation]  branch operation head- reject LoanApplication.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Reject Loan Application   ${loanuid}  ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationStatus[3]}

JD-TC-BranchOperationHead-UH1

    [Documentation]  branch operation head- create location.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY}=  db.get_date_by_timezone  ${tz}
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element     ${parkingType} 
    ${24hours}    Random Element    ['True','False']
    ${url}=   FakerLibrary.url
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"       "${NO_PERMISSION_FOR_REQUEST}"
    

JD-TC-BranchOperationHead-UH2

    [Documentation]  branch operation head- update location.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${city1}=   get_place
    ${latti1}=  get_latitude
    ${longi1}=  get_longitude
    ${postcode1}=  FakerLibrary.postcode
    ${address1}=  get_address
    ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours1}    Random Element    ['True','False']
    ${resp}=  Update Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${locid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"


JD-TC-BranchOperationHead-UH3

    [Documentation]  branch operation head- create branch.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"


JD-TC-BranchOperationHead-UH4

    [Documentation]  branch operation head- update branch.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Update BranchMaster    ${branchid1}    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"


JD-TC-BranchOperationHead-UH5

    [Documentation]  branch operation head- create partner.

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone1}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealername}=  FakerLibrary.bs
    ${dealerlname}=  FakerLibrary.last_name

    ${resp}=  Generate Phone Partner Creation    ${phone1}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname1}=  FakerLibrary.name
    ${dealerlname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone1}   ${OtpPurpose['ProviderVerifyPhone']}   ${dealerfname1}   ${dealerlname1}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}       "${NO_PERMISSION_FOR_REQUEST}"

*** Comments ***
JD-TC-BranchOperationHead-12

    [Documentation]   Create Branch operation Head(create user with role) and Create a partner by sales officer
    ...   then branch operation head - view partner.
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id2}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
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

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id2}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id2}  ${resp.json()['serviceSubSector']['id']}

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

    ${resp}=  partnercategorytype   ${account_id2}
    ${resp}=  partnertype           ${account_id2}
    ${resp}=  categorytype          ${account_id2}
    ${resp}=  tasktype              ${account_id2}
    ${resp}=  loanStatus            ${account_id2}
    ${resp}=  loanProducttype       ${account_id2}
    ${resp}=  LoanProductCategory   ${account_id2}
    ${resp}=  loanProducts          ${account_id2}
    ${resp}=  loanScheme            ${account_id2}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${HLPUSERNAME17}'
                clear_users  ${user_phone}
            END
        END
    END

    reset_user_metric  ${account_id2}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200




    
    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${boh_id1}=  Create Sample User 
    Set Suite Variable  ${boh_id1}
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

# ....User  :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all

    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id} 
    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 3 :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}

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

    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername1}  ${resp.json()['partnerName']}

