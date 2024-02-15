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

${invoiceAmount}    60000
${downpaymentAmount}    2000
${requestedAmount}    58000
${sanctionedAmount}   58000

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
${start}   12

${customerEducation}    1
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
    
    FOR   ${a}  IN RANGE   ${length}   
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
        # Continue For Loop If  '${pkgId}' == '${licId}'

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 2 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']} and '${pkgId}' == '${licId}'
            Exit For Loop
        END
    END

    RETURN  ${MUSERNAME${a}}


*** Test Cases ***

JD-TC-SalesExecutiveWithRBAC-1
                                  
    [Documentation]               Create Partner Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${HLMUSERNAME20}'
            clear_users  ${user_phone}
        END
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
    Set Suite Variable  ${SEUSERNAME1}  ${resp.json()['mobileNo']}





    ${se_id2}=  Create Sample User 
    Set Suite Variable  ${se_id2}
    
    ${resp}=  Get User By Id  ${se_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SEUSERNAME2}  ${resp.json()['mobileNo']}

    ${se_id3}=  Create Sample User 
    Set Suite Variable  ${se_id3}
    
    ${resp}=  Get User By Id  ${se_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SEUSERNAME3}  ${resp.json()['mobileNo']}

    ${se_id4}=  Create Sample User 
    Set Suite Variable  ${se_id4}
    
    ${resp}=  Get User By Id  ${se_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SEUSERNAME4}  ${resp.json()['mobileNo']}







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
    Set Test Variable  ${BMUSERNAME1}  ${resp.json()['mobileNo']}

    ${sh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${SHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bh_id1}=  Create Sample User 
    
    ${resp}=  Get User By Id  ${bh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BHUSERNAME1}  ${resp.json()['mobileNo']}


# ....User 1 :Bussiness Head...

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

# ....... Create Branch 2 in same Location ....

    ${branchCode2}=    FakerLibrary.Random Number
    ${branchName2}=    FakerLibrary.name
    Set Suite Variable  ${branchName2}

    ${resp}=    Create BranchMaster    ${branchCode2}    ${branchName2}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# ....... Create branch 3 in another location......


    ${branchCode3}=    FakerLibrary.Random Number
    ${branchName3}=    FakerLibrary.name
    Set Suite Variable  ${branchName3}

    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pin2}  ${resp.json()['pinCode']}

    ${resp}=  Get LocationsByPincode     ${pin2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state2}=    Evaluate     "${state2}".title()
    ${state2}=    String.RemoveString  ${state2}    ${SPACE}
    Set Suite Variable    ${state2}

    ${resp}=    Create BranchMaster    ${branchCode3}    ${branchName3}    ${locId1}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid3}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid3}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


# ....User 1 :Sales Officer Under Branch 1...

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

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 2 :Sales Executive  Under Branch 1...

    ${location_id}=  Create List    ${locid}
    ${branches_id}=  Create List    ${branchid1} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1a}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles1a}=  Create List   ${role1a}

    ${user_ids}=  Create List   ${se_id2}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles1a} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${se_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 3 :Sales Officer  Under Branch 2...

    ${location_id}=  Create List    ${locid}
    ${branches_id}=  Create List    ${branchid2} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1a}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles1a}=  Create List   ${role1a}

    ${user_ids}=  Create List   ${se_id3}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles1a} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${se_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 4 :Sales Officer  Under Branch 3 ...

    ${location_id}=  Create List    ${locid1}
    ${branches_id}=  Create List    ${branchid3} 
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1a}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles1a}=  Create List   ${role1a}

    ${user_ids}=  Create List   ${se_id4}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles1a} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${se_id4}
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

    ${location_id}=  Create List    ${locId}   ${locid}
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

    ${location_id}=  Create List    ${locId}   ${locid}
    ${branches_id}=  Create List    ${branchid1} 
    ${users_id}=  Create List      ${bch_id1}   ${so_id1}
    # ${partner}=  Create List      all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    
    # partner=${partner}

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
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



# ....User  :Branch Manager...

    ${role1}=  Create Dictionary   id=${role_id3}  roleName=${role_name3}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bm_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  Get User By Id  ${sh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}

# ..... Assigning Branches to Users .........

    ${userids}=  Create List  ${so_id1}   ${bch_id1}
    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users    ${userids}  ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List  ${se_id1}   ${bch_id1}
    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users    ${userids}  ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# ...... Reset Passwords ...................

    ${resp}=  SendProviderResetMail   ${SEUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SEUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  SendProviderResetMail   ${SEUSERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SEUSERNAME2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

# .....Create Dealer By Sales Officer.......

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
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
   
    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone}  555${PH_Number}
    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    Set Suite Variable    ${dealerfname}
    Set Suite Variable    ${dealerlname}
    ${dealername}=  FakerLibrary.bs
   
    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
   
    ${branch}=      Create Dictionary   id=${branchid1}
    Set Suite Variable  ${branch}

    ${resp}=  Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuid1}  ${resp.json()['uid']}

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-SalesExecutiveWithRBAC-2
                                  
    [Documentation]               Create Partner Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


JD-TC-SalesExecutiveWithRBAC-3
                                  
    [Documentation]               View Partner Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnerName}  ${resp.json()['partnerName']}


JD-TC-SalesExecutiveWithRBAC-4
                                  
    [Documentation]               Partner Approval request Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-SalesExecutiveWithRBAC-5
                                  
    [Documentation]               Create Lead Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# .....Approve Dealer By Head......

    # ${resp}=  Encrypted Provider Login  ${BHUSERNAME1}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME20}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${resp}=  SendProviderResetMail   ${BOHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BOHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

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

    # ${resp}=    sales officer verification    ${partuid1}    ${bool[1]}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname_A}=  FakerLibrary.firstname

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

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite Variable  ${loanid}    ${resp.json()['id']}
        Set Suite Variable  ${loanuid}    ${resp.json()['uid']}
        
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
        Set Suite Variable  ${loanid}    ${resp.json()['id']}
        Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    END


JD-TC-SalesExecutiveWithRBAC-6
                                  
    [Documentation]               View Lead Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid   ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}    ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no}  ${resp.json()['referenceNo']}


JD-TC-SalesExecutiveWithRBAC-7
                                  
    [Documentation]               Update Lead, Create Loan and update Application Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
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


JD-TC-SalesExecutiveWithRBAC-8
                                  
    [Documentation]               Loan Applcation Approval Request Using Sales Executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Loan Application Approval        ${loanuid}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-SalesExecutiveWithRBAC-9
                                  
    [Documentation]               Verify partner loan application Using Sales executive Role with RBAC

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    # Set Test Variable  ${email}  ${phone}${partownername}.${test_mail}
    Set Test Variable  ${email}  ${dealerlname}.${test_mail}

    ${resp}=    Generate OTP for partner Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify OTP for Partner Email    ${email}  ${partid1}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Partner by UID    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Partner Reset Password    ${account_id1}  ${phone}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    511 
    Should Be Equal As Strings   ${resp.json()}   otp authentication needed
    # Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Verify Otp For Login Partner  ${phone}  ${OtpPurpose['Authentication']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Complete Partner Reset Password    ${account_id1}  ${phone}  ${PASSWORD}  ${token}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Login Partner with Password    ${account_id1}  ${phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consnum}  555${PH_Number}

    ${resp}=  Get Partner Loan Application Consumer Details with filter  phoneNo-eq=${consnum}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=18   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
        ${custDetails}=  Create Dictionary  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consnum}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${consnum}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    
    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

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

    ${resp}=   Requst For Partner Aadhar Validation    ${custid}    ${loanuid}    ${consnum}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${custid}    ${loanuid}    ${consnum}    ${pan}    ${panAttachments}
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

    ${loanProducts}=    Create List 
    ${loanPrdts}=    Create Dictionary    id=${Productid}
    Append To List  ${loanProducts}  ${loanPrdts}

    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}
    ${employeeCode}=    FakerLibrary.Random Number

    ${montlyIncome}    FakerLibrary.Random Number
    ${nomineedob}=  FakerLibrary.Date
    Set Suite Variable  ${nomineedob} 

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${nominenum}  555${PH_Number}

    ${LoanApplicationKycList}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominenum}  customerEducation=${customerEducation}  customerEmployement=${customerEmployement}  salaryRouting=${salaryRouting}  familyDependants=${familyDependants}  earningMembers=${earningMembers}  existingCustomer=${existingCustomer}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus}  ownedMovableAssets=${ownedMovableAssets}  vehicleNo=${vehicleNo}  goodsFinanced=${goodsFinanced}  guarantorName=${guarantorName}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Approval Loan Application    ${loanuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-SalesExecutiveWithRBAC-10
                                  
    [Documentation]              invoice updation Using Sales Executive Role with RBAC

    ${resp}=  SendProviderResetMail   ${BCHUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCHUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    Set Suite Variable    ${loanProduct} 
    ${note}=      FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${sanctionedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
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

    ${resp}=  salesofficer Approval    ${loanuid}    ${sch1}    ${tenu1}    ${noOfAdvanceEmi}    ${dayofmonth}    partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[6]}

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    


JD_TC_SalesExecutiveWithRBAC-UH1

    [Documentation]               create location in sales Executive

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${salesofrid}    ${resp.json()['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable   ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  30  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
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
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}


JD_TC_SalesExecutiveWithRBAC-UH2

    [Documentation]               update location in sales Executive

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${salesofrid}    ${resp.json()['id']}

    ${resp}=  UpdateBaseLocation  ${locId}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${city1}=   get_place
    # Set Suite Variable  ${city1}
    # ${latti1}=  get_latitude
    # Set Suite Variable  ${latti1}
    # ${longi1}=  get_longitude
    # Set Suite Variable  ${longi1}
    # ${postcode1}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode1}
    # ${address1}=  get_address
    # Set Suite Variable  ${address1}
    ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city1}
    Set Suite Variable  ${latti1}
    Set Suite Variable  ${longi1}
    Set Suite Variable  ${postcode1}
    Set Suite Variable  ${address1}
    ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
    Set Suite Variable  ${parking_type1}
    ${24hours1}    Random Element    ['True','False']
    Set Suite Variable  ${24hours1}
    ${resp}=  Update Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${locId} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}

JD_TC_SalesExecutiveWithRBAC-UH3

    [Documentation]               View loan by other sales executive who is in the same branch

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC_SalesExecutiveWithRBAC-UH4

    [Documentation]               View loan by other sales executive who is in the different branch but in same location

    ${resp}=  SendProviderResetMail   ${SEUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SEUSERNAME3}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content} 
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC_SalesExecutiveWithRBAC-UH5

    [Documentation]               View loan by other sales executive who is in the different branch and different location

    ${resp}=  SendProviderResetMail   ${SEUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${SEUSERNAME4}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content} 
    Should Be Equal As Strings     ${resp.status_code}    422


JD-TC_SalesExecutiveWithRBAC-UH6

    [Documentation]               Create branch Master using Sales executive

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCodeA}=    FakerLibrary.Random Number
    ${branchNameA}=    FakerLibrary.name
    Set Suite Variable  ${branchNameA}

    ${resp}=    Create BranchMaster    ${branchCodeA}    ${branchNameA}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}


JD-TC_SalesExecutiveWithRBAC-UH7

    [Documentation]               Update branch Master using Sales executive

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCodeex}=    FakerLibrary.Random Number
    ${branchNameex}=    FakerLibrary.name
    Set Suite Variable  ${branchNameex}

    ${resp}=    Update BranchMaster    ${branchid1}    ${branchCodeex}    ${branchNameex}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}







JD-TC_SalesExecutiveWithRBAC-UH8

    [Documentation]              Partner approval using Sales Executive

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${partnern1}  555${PH_Number}
   
    ${resp}=  Generate Phone Partner Creation    ${partnern1}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname}=  FakerLibrary.name
    ${dealerlname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    Set Suite Variable    ${dealerfname}
    Set Suite Variable    ${dealerlname}
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${partnern1}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid1}  ${resp.json()['id']}
    Set Suite Variable  ${partuidA}  ${resp.json()['uid']}

    ${resp}=    Get Partner by UID    ${partuidA}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Approval Request    ${partuidA}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuidA}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}

    
JD-TC_SalesExecutiveWithRBAC-UH9

    [Documentation]              Update Sales Executive using Sales Officer

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Partner Approved    ${partuidA}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuidA}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}


JD-TC_SalesExecutiveWithRBAC-UH10

    [Documentation]              Update Credit executive using Sales Officer

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuidA}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuidA}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}


JD-TC_SalesExecutiveWithRBAC-UH11

    [Documentation]              Activate Partner using Sales Executive

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuidA}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Activate Partner    ${partuidA}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}

















JD-TC_SalesOfficerWithRBAC-UH12

    [Documentation]              Loan Application Approval using Sales Officer

    ${resp}=  Encrypted Provider Login  ${BOHUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Activate Partner    ${partuidA}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Partner Reset Password    ${account_id1}  ${phone}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    511 
    Should Be Equal As Strings   ${resp.json()}   otp authentication needed
    # Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Verify Otp For Login Partner  ${phone}  ${OtpPurpose['Authentication']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Complete Partner Reset Password    ${account_id1}  ${phone}  ${PASSWORD}  ${token}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Login Partner with Password    ${account_id1}  ${phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consnum}  555${PH_Number}

    ${resp}=  Get Partner Loan Application Consumer Details with filter  phoneNo-eq=${consnum}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=18   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
        ${custDetails}=  Create Dictionary  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consnum}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${consnum}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    
    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

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

    ${resp}=   Requst For Partner Aadhar Validation    ${custid}    ${loanuid}    ${consnum}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${custid}    ${loanuid}    ${consnum}    ${pan}    ${panAttachments}
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

    ${loanProducts}=    Create List 
    ${loanPrdts}=    Create Dictionary    id=${Productid}
    Append To List  ${loanProducts}  ${loanPrdts}

    ${loanScheme}=     Create Dictionary    id=${Schemeid}  name=${Schemename}
    ${employeeCode}=    FakerLibrary.Random Number

    ${montlyIncome}    FakerLibrary.Random Number
    ${nomineedob}=  FakerLibrary.Date
    Set Suite Variable  ${nomineedob} 

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${nominenum}  555${PH_Number}

    ${LoanApplicationKycList}=    Create Dictionary  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}  nomineeDob=${nomineedob}  nomineePhone=${nominenum}  customerEducation=${customerEducation}  customerEmployement=${customerEmployement}  salaryRouting=${salaryRouting}  familyDependants=${familyDependants}  earningMembers=${earningMembers}  existingCustomer=${existingCustomer}  noOfYearsAtPresentAddress=${noOfYearsAtPresentAddress}  currentResidenceOwnershipStatus=${currentResidenceOwnershipStatus}  ownedMovableAssets=${ownedMovableAssets}  vehicleNo=${vehicleNo}  goodsFinanced=${goodsFinanced}  guarantorName=${guarantorName}  guarantorType=${nomineeType[1]}  id=${kyid}
    Log  ${LoanApplicationKycList}

    ${resp}=    Verify Partner loan Bank Details     ${loanuid}  ${loanProducts}  ${category}  ${type}   ${loanproductcatid}   ${loanproductSubcatid}  ${partner}  ${invoiceAmount}  ${downpaymentAmount}  ${requestedAmount}  ${emiPaidAmountMonthly}  ${bool[1]}  ${employeeCode}  ${loanid}  ${LoanApplicationKycList}      
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Approval Loan Application    ${loanuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    Set Suite Variable    ${loanProduct} 

    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${sanctionedAmount}    loanProduct=${loanProduct}    note=${note}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_FOR_REQUEST}


JD-TC_SalesOfficerWithRBAC-UH13

    [Documentation]              change status to operation verification using Sales Officer

    ${resp}=  Encrypted Provider Login  ${BCHUSERNAME1}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${SEUSERNAME1}  ${PASSWORD}
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

    ${resp}=  salesofficer Approval    ${loanuid}    ${sch1}    ${tenu1}    ${noOfAdvanceEmi}    ${dayofmonth}     partner=${partner}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Acceptance Phone    ${consumernumber}  ${email}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Otp for Consumer Loan Acceptance Phone    ${consumernumber}    ${OtpPurpose['Authentication']}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[6]}

    ${resp}=  Partner Accepted    ${loanuid}    ${so_id1}    ${pdffile}    ${fileSize}   ${caption}  ${fileType}    ${LoanAction[0]}  ${EMPTY}  invoice  ${order}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=      FakerLibrary.sentence

    ${resp}=    Loan Application Operational Approval   ${loanuid}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200