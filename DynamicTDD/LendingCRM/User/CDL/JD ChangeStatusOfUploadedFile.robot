*** Settings ***
Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         RBAC
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

@{emptylist}
${invoiceAmount}                     80000
${downpaymentAmount}                 20000
${requestedAmount}                   60000
${sanctionedAmount}                  60000

${jpgfile}                           /ebs/TDD/uploadimage.jpg
${pngfile}                           /ebs/TDD/upload.png
${pdffile}                           /ebs/TDD/sample.pdf
${jpgfile2}                          /ebs/TDD/small.jpg
${gif}                               /ebs/TDD/sample.gif
${xlsx}                              /ebs/TDD/qnr.xlsx

${order}                             0
${fileSize}                          0.00458

${aadhaar}                           555555555555

${monthlyIncome}                     80000
${emiPaidAmountMonthly}              2000
${start}                             12

${customerEducation}                 1    
${customerEmployement}               1   
${salaryRouting}                     1
${familyDependants}                  1
${noOfYearsAtPresentAddress}         1  
${currentResidenceOwnershipStatus}   1  
${ownedMovableAssets}                1
${goodsFinanced}                     1
${earningMembers}                    1
${existingCustomer}                  1
${autoApprovalUptoAmount}            50000
${autoApprovalUptoAmount2}           70000
${cibilScore}                        850

${minCreditScoreRequired}            50
${minEquifaxScoreRequired}           690
${minCibilScoreRequired}             690
${minAge}                            23
${maxAge}                            60
${minAmount}                         5000
${maxAmount}                         300000


*** Test Cases ***

JD-TC-Change Status Of Uploaded File-1
                                  
    [Documentation]               Update File to Tempary Location

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

# ..... SignUp Business Head

    ${NBFCPUSERNAME1}=  Evaluate  ${PUSERNAME}+5478425
    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp              ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${NBFCPUSERNAME1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}    202
    
    ${resp}=  Account Activation          ${NBFCPUSERNAME1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Account Set Credential      ${NBFCPUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${NBFCPUSERNAME1}
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${NBFCPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    
    Set Suite Variable  ${BH}   ${decrypted_data['id']}
    Set Test Variable   ${lic_id}         ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Should Be Equal As Strings            ${resp.json()['enableRbac']}    ${bool[0]}
    Should Be Equal As Strings            ${resp.json()['enableCdl']}     ${bool[0]}
    Should Be Equal As Strings            ${resp.json()['cdlRbac']}       ${bool[0]}

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable Main RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings        ${resp1.status_code}  200
    END

    IF  ${resp.json()['cdlRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Should Be Equal As Strings            ${resp.status_code}  200
    Should Be Equal As Strings            ${resp.json()['enableRbac']}    ${bool[1]}
    Should Be Equal As Strings            ${resp.json()['enableCdl']}     ${bool[1]}
    Should Be Equal As Strings            ${resp.json()['cdlRbac']}       ${bool[1]}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan    autoEmiDeductionRequire=${bool[1]}   partnerRequired=${bool[0]}  documentSignatureRequired=${bool[0]}   digitalSignatureRequired=${bool[1]}   emandateRequired=${bool[1]}   creditScoreRequired=${bool[1]}   equifaxScoreRequired=${bool[1]}   cibilScoreRequired=${bool[1]}   minCreditScoreRequired=${minCreditScoreRequired}   minEquifaxScoreRequired=${minEquifaxScoreRequired}   minCibilScoreRequired=${minCibilScoreRequired}   minAge=${minAge}   maxAge=${maxAge}   minAmount=${minAmount}   maxAmount=${maxAmount}   bankStatementVerificationRequired=${bool[1]}   eStamp=DIGIO 
    Log  ${resp.content}
    Should Be Equal As Strings            ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200

    ${resp}=  Get roles
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${role_id1}       ${resp.json()[0]['id']}
    Set Suite Variable  ${role_name1}     ${resp.json()[0]['roleName']}
    Set Suite Variable  ${capability1}    ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id2}       ${resp.json()[1]['id']}
    Set Suite Variable  ${role_name2}     ${resp.json()[1]['roleName']}
    Set Suite Variable  ${capability2}    ${resp.json()[1]['capabilityList']}

    Set Suite Variable  ${role_id3}       ${resp.json()[2]['id']}
    Set Suite Variable  ${role_name3}     ${resp.json()[2]['roleName']}
    Set Suite Variable  ${capability3}    ${resp.json()[2]['capabilityList']}

    Set Suite Variable  ${role_id4}       ${resp.json()[3]['id']}
    Set Suite Variable  ${role_name4}     ${resp.json()[3]['roleName']}
    Set Suite Variable  ${capability4}    ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}       ${resp.json()[4]['id']}
    Set Suite Variable  ${role_name5}     ${resp.json()[4]['roleName']}
    Set Suite Variable  ${capability5}    ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id6}       ${resp.json()[5]['id']}
    Set Suite Variable  ${role_name6}     ${resp.json()[5]['roleName']}
    Set Suite Variable  ${capability6}    ${resp.json()[5]['capabilityList']}

    Set Suite Variable  ${role_id7}       ${resp.json()[6]['id']}
    Set Suite Variable  ${role_name7}     ${resp.json()[6]['roleName']}
    Set Suite Variable  ${capability7}    ${resp.json()[6]['capabilityList']}

    Set Suite Variable  ${role_id8}       ${resp.json()[7]['id']}
    Set Suite Variable  ${role_name8}     ${resp.json()[7]['roleName']}
    Set Suite Variable  ${capability8}    ${resp.json()[7]['capabilityList']}

    Set Suite Variable  ${role_id9}       ${resp.json()[8]['id']}
    Set Suite Variable  ${role_name9}     ${resp.json()[8]['roleName']}
    Set Suite Variable  ${capability9}    ${resp.json()[8]['capabilityList']}

    Set Suite Variable  ${role_id10}      ${resp.json()[9]['id']}
    Set Suite Variable  ${role_name10}    ${resp.json()[9]['roleName']}
    Set Suite Variable  ${capability10}   ${resp.json()[9]['capabilityList']}

    Set Suite Variable  ${role_id11}      ${resp.json()[10]['id']}
    Set Suite Variable  ${role_name11}    ${resp.json()[10]['roleName']}
    Set Suite Variable  ${capability11}   ${resp.json()[10]['capabilityList']}

    Set Suite Variable  ${role_id12}      ${resp.json()[11]['id']}
    Set Suite Variable  ${role_name12}    ${resp.json()[11]['roleName']}
    Set Suite Variable  ${capability12}   ${resp.json()[11]['capabilityList']}

    Set Suite Variable  ${role_id13}      ${resp.json()[12]['id']}
    Set Suite Variable  ${role_name13}    ${resp.json()[12]['roleName']}
    Set Suite Variable  ${capability13}   ${resp.json()[12]['capabilityList']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id1}       ${resp.json()['id']}
    Set Suite Variable                    ${sub_domain_id}     ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.json()}
        Should Be Equal As Strings        ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings            ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department      ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings        ${resp1.status_code}  200
        Set Test Variable  ${dep_id}      ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}      ${resp.json()['departments'][0]['departmentId']}
    END

# ..... Default Status Updation for loan creation....

    ${resp}=  partnercategorytype         ${account_id1}
    ${resp}=  partnertype                 ${account_id1}
    ${resp}=  categorytype                ${account_id1}
    ${resp}=  tasktype                    ${account_id1}
    ${resp}=  loanStatus                  ${account_id1}
    ${resp}=  loanProducttype             ${account_id1}
    ${resp}=  LoanProductCategory         ${account_id1}
    ${resp}=  loanProducts                ${account_id1}
    ${resp}=  loanScheme                  ${account_id1}
    ${resp}=  CDLcategorytype             ${account_id1}
    ${resp}=  CDLtype                     ${account_id1}
    ${resp}=  CDLEnqStatus                   ${account_id1}

    

    reset_user_metric  ${account_id1}

# ..... Create Sample User for Branch Sales Head

    ${BSH}=  Create Sample User 
    Set Suite Variable                    ${BSH}
    
    ${resp}=  Get User By Id              ${BSH}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${BSH_USERNAME}   ${resp.json()['mobileNo']}

# ..... Create Sample User for Branch Manager

    ${BM}=  Create Sample User 
    Set Suite Variable                    ${BM}

    ${resp}=  Get User By Id              ${BM}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Test Variable  ${BM_USERNAME}     ${resp.json()['mobileNo']}

# ..... Create Sample User for Branch Operational Head

    ${BOH}=  Create Sample User 
    Set Suite Variable                    ${BOH}

    ${resp}=  Get User By Id              ${BOH}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${BOH_USERNAME}   ${resp.json()['mobileNo']}

# ..... Create Sample User for Branch Credit Head

    ${BCH}=  Create Sample User 
    Set Suite Variable                    ${BCH}
    
    ${resp}=  Get User By Id              ${BCH}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${BCH_USERNAME}   ${resp.json()['mobileNo']}

# ..... Create Sample User for Sales Executive

    ${SE}=  Create Sample User 
    Set suite Variable                    ${SE}
    
    ${resp}=  Get User By Id              ${SE}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${SE_USERNAME}    ${resp.json()['mobileNo']}

# ..... Create Sample User for Sales Officer

    ${SO}=  Create Sample User 
    Set suite Variable                    ${SO}
    
    ${resp}=  Get User By Id              ${SO}
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable  ${SO_USERNAME}    ${resp.json()['mobileNo']}

# ..... Create Sample User for NH Sales

    ${NHSO}=  Create Sample User 
    Set suite Variable                     ${NHSO}
    
    ${resp}=  Get User By Id               ${NHSO}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${NHSO_USRNME}     ${resp.json()['mobileNo']}

# ..... Create Sample User for NH Operation

    ${NHO}=  Create Sample User 
    Set suite Variable                     ${NHO}
    
    ${resp}=  Get User By Id               ${NHO}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${NHO_USERNAME}    ${resp.json()['mobileNo']}

# ..... Create Sample User for NH Credit

    ${NHC}=  Create Sample User 
    Set suite Variable                     ${NHC}
    
    ${resp}=  Get User By Id               ${NHC}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${NHC_USERNME}     ${resp.json()['mobileNo']}

# ..... Create Sample User for Regional Manager

    ${RM}=  Create Sample User 
    Set suite Variable                     ${RM}
    
    ${resp}=  Get User By Id               ${RM}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${RM_USERNAME}     ${resp.json()['mobileNo']}

# ..... Create Sample User for Auditor

    ${ADT}=  Create Sample User 
    Set suite Variable                     ${ADT}
    
    ${resp}=  Get User By Id               ${ADT}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${ADT_USERNME}     ${resp.json()['mobileNo']}

# ..... Create Sample User for Support User

    ${SPT}=  Create Sample User 
    Set suite Variable                     ${SPT}
    
    ${resp}=  Get User By Id               ${SPT}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Set Suite Variable  ${SPT_USERNME}     ${resp.json()['mobileNo']}



# ....User 1 :Bussiness Head...

    ${location_id}=  Create List           all
    ${branches_id}=  Create List           all
    ${users_id}=     Create List           all
    ${partners}=     Create List           all
    ${user_scope}=   Create Dictionary     businessLocations=${location_id}  branches=${branches_id}   users=${users_id}     partners=${partners}
    ${role1}=        Create Dictionary     id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}  scope=${user_scope}  
    ${user_roles}=   Create List           ${role1}

    ${user_ids}=  Create List              ${BH}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    
    ${resp}=  Get User By Id               ${BH}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}  200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}               ${role_id1}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    Should Be Equal As Strings             ${resp.json()['defaultRoleId']}                    ${role_id1}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                  ${role_name1}


# .....Create Location.....

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}

        ${resp}=   Get Location ById       ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings         ${resp.status_code}  200
        Set Suite Variable                 ${locname}                   ${resp.json()['place']}
        Set Suite Variable                 ${address1}                  ${resp.json()['address']}
        ${address2}                        FakerLibrary.Street name
        Set Suite Variable                 ${address2}
        
    ELSE
        Set Suite Variable                 ${locId}                     ${resp.json()[0]['id']}
        Set Suite Variable                 ${locname}                   ${resp.json()[0]['place']}
        Set Suite Variable                 ${address1}                  ${resp.json()[0]['address']}
        ${address2}                        FakerLibrary.Street name
        Set Suite Variable                 ${address2}
    END                         

    ${resp}=   Get Location ById           ${locid}  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}      200
    Set Suite Variable                     ${locname1}              ${resp.json()['place']}
    
# .... Create Branch1....

    ${branchCode}=                         FakerLibrary.Random Number
    ${branchName}=                         FakerLibrary.name
    Set Suite Variable                     ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate                  "${state}".title()
    # ${state}=    String.RemoveString       ${state}    ${SPACE}
    Set Suite Variable                     ${state}
    Set Suite Variable                     ${district}
    Set Suite Variable                     ${pin}
    
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch   ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings         ${resp1.status_code}  200
    END
   
    ${resp}=    Create BranchMaster        ${branchCode}    ${branchName}    ${locId}    ${status[0]}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Set Suite Variable                     ${branchid}            ${resp.json()['id']}

    ${resp}=    Change Branch Status       ${branchid}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....User 1 :Sales Officer...

    ${location_id}=     Create List        ${locId}   
    ${branches_id}=     Create List        ${branchid} 
    ${user_scope}=      Create Dictionary  businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=    Create List

    ${role1}=           Create Dictionary  id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=      Create List        ${role1}

    ${user_ids}=        Create List        ${SO} 

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${SO}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id7}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name7}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability7}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name7}

# ....User  :Sales Executive...

    ${role1}=  Create Dictionary           id=${role_id6}  roleName=${role_name6}  defaultRole=${bool[1]}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List            ${role1}
    ${user_ids}=  Create List              ${SE}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${SE}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id6}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name6}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability6}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name6}

# ....User  :Branch Credit Head...

    ${location_id}=     Create List        ${locId}   
    ${branches_id}=     Create List        ${branchid} 
    ${users_id}=        Create List        ${SO}
    ${user_scope}=      Create Dictionary  businessLocations=${location_id}    branches=${branches_id}    users=${users_id}
    ${role1}=           Create Dictionary  id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}  scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=      Create List        ${role1}
    ${user_ids}=        Create List        ${BCH}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${BCH}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id5}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name5}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability5}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name5}

# ....User  :Branch Operation Head...

    ${location_id}=     Create List        ${locId}   
    ${branches_id}=     Create List        ${branchid} 
    ${users_id}=        Create List        ${BCH}   ${SO}
    ${partners}=        Create List        all
    ${user_scope}=      Create Dictionary  businessLocations=${location_id}    branches=${branches_id}      users=${users_id}    partners=${partners}
    ${role1}=           Create Dictionary  id=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=      Create List        ${role1}
    ${user_ids}=        Create List        ${BOH}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${BOH}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id4}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name4}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability4}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name4}

# ....User  :Branch Manager...

    ${role1}=           Create Dictionary  id=${role_id3}  roleName=${role_name3}  defaultRole=${bool[1]}   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=      Create List        ${role1}
    ${user_ids}=        Create List        ${BM}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${BM}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id3}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name3}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability3}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name3}

# ....User  :Sales Head...

    ${role1}=           Create Dictionary  id=${role_id2}  roleName=${role_name2}  defaultRole=${bool[1]}  scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=      Create List        ${role1}
    ${user_ids}=        Create List        ${BSH}  

    ${resp}=  Append User Scope            ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  Get User By Id               ${BSH}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['id']}                 ${role_id2}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['roleName']}           ${role_name2}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['defaultRole']}        ${bool[1]}
    Should Be Equal As Strings             ${resp.json()['userRoles'][0]['capabilities']}       ${capability2}
    Should Be Equal As Strings             ${resp.json()['defaultRoleName']}                    ${role_name2}

# ....Assiging Branch to users

    ${userids}=         Create List        ${SO}   ${BCH}
    ${branch}=          Create Dictionary  id=${branchid}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users  ${userids}     ${branch}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200

# .....Create Dealer By Sales Officer.......

    ${resp}=    Reset LoginId  ${SO}  ${SO_USERNAME}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${SO_USERNAME}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${SO_USERNAME}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${SO_USERNAME}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${categoryid}         ${resp.json()[0]['id']}
    Set Suite Variable                     ${categoryname}       ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${typeid}             ${resp.json()[0]['id']}
    Set Suite Variable                     ${typename}           ${resp.json()[0]['name']}

    ${resp}=  Get Loan Application Status  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE    ${len}
        Set Suite Variable                 ${status_id${i}}      ${resp.json()[${i}]['id']}
        Set Suite Variable                 ${status_name${i}}    ${resp.json()[${i}]['name']}
    END

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${Productid}          ${resp.json()[0]['id']}
    Set Suite Variable                     ${productname}        ${resp.json()[0]['productName']}
    Set Suite Variable                     ${Productid1}         ${resp.json()[1]['id']}
    Set Suite Variable                     ${productname1}       ${resp.json()[1]['productName']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${Schemeid}           ${resp.json()[0]['id']}
    Set Suite Variable                     ${Schemename}         ${resp.json()[0]['schemeName']} 
    Set Suite Variable                     ${Schemeid1}          ${resp.json()[1]['id']}
    Set Suite Variable                     ${Schemename1}        ${resp.json()[1]['schemeName']} 
    Set Suite Variable                     ${Schemeid2}          ${resp.json()[2]['id']}
    Set Suite Variable                     ${Schemename2}        ${resp.json()[2]['schemeName']}

    ${resp}=    Get Partner Category
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${Pcategoryid}        ${resp.json()[0]['id']}
    Set Suite Variable                     ${Pcategoryname}      ${resp.json()[0]['name']}

    ${resp}=    Get Partner Type
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${Ptypeid}            ${resp.json()[0]['id']}
    Set Suite Variable                     ${Ptypename}          ${resp.json()[0]['name']}

    ${resp}=    Get Loan Application ProductCategory
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${loanproductcatid1}   ${resp.json()[0]['id']}
    
    ${s_len}=  Get Length                  ${resp.json()}
    @{loanproductcatid}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List                     ${loanproductcatid}   ${resp.json()[${i}]['id']}
    END
    Log  ${loanproductcatid}

    ${resp}=  LoanProductSubCategory       ${account_id1}    @{loanproductcatid}

    ${resp}=                               Get Loan Application ProductSubCategory   ${loanproductcatid[0]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}      200
    Set Suite Variable                     ${loanproductSubcatid}   ${resp.json()[0]['id']}
   
    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable                     ${phone}  555${PH_Number}

    ${dealerfname}=                        FakerLibrary.name
    ${dealername}=                         FakerLibrary.bs
    ${dealerlname}=                        FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth    minimum_age=23   maximum_age=55
    ${dob}=  Convert To String             ${dob} 
    Set Test Variable                      ${email}  ${phone}.${dealerfname}.${test_mail}
   
    ${resp}=                               Generate Phone Partner Creation   ${phone}    ${countryCodes[0]}    partnerName=${dealername}   partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
   
    ${branch}=      Create Dictionary      id=${branchid}

    ${resp}=                               Verify Phone Partner Creation    ${phone}   ${OtpPurpose['ProviderVerifyPhone']}    ${dealerfname}   ${dealerlname}   branch=${branch}    partnerUserFirstName=${dealerfname}  partnerUserLastName=${dealerlname}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200
    Set Suite Variable                     ${partid1}            ${resp.json()['id']}
    Set Suite Variable                     ${partuid1}           ${resp.json()['uid']} 

    ${resp}=                               Generate OTP for partner Email  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=                               Verify OTP for Partner Email  ${email}  ${partid1}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200

# ....... Dealer owner photo .......

    ${resp}=  db.getType                   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary      ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType}
    ${caption}=                            Fakerlibrary.Sentence
    Set Suite Variable   ${caption}

    ${resp}=                               upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file  ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}   200


JD-TC-Change Status Of Uploaded File-UH1
                                  
    [Documentation]               Change satus of uploaded file where QNR Status where qnr Status is INCOMPLETE

    ${resp}=  Encrypted Provider Login  ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}    change status of the uploaded file    ${QnrStatus[0]}    ${partid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings     ${resp.json()}    ${S3_UPLOAD_FAILED}


JD-TC-Change Status Of Uploaded File-UH2
                                  
    [Documentation]               Change satus of uploaded file with invalid partner id

    ${resp}=  Encrypted Provider Login  ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv_pid}    FakerLibrary.Random Number

    ${resp}    change status of the uploaded file    ${QnrStatus[0]}    ${inv_pid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_INPUT}

JD-TC-Change Status Of Uploaded File-UH3
                                  
    [Documentation]               Change satus of uploaded file without login

    ${resp}    change status of the uploaded file    ${QnrStatus[0]}    ${partid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}