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
Variables          /ebs/TDD/varfiles/musers.py
Variables          /ebs/TDD/varfiles/hl_musers.py


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

JD-TC-RequstForAadharValidation-1
                                  
    [Documentation]               requst for aadhar validation by varify phone number
    
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

    ${NBFCMUSERNAME1}=  Evaluate  ${MUSERNAME}+2354258
    ${highest_package}=  get_highest_license_pkg

    ${resp}=  Account SignUp              ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${NBFCMUSERNAME1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}    200
    
    ${resp}=  Account Activation          ${NBFCMUSERNAME1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Account Set Credential      ${NBFCMUSERNAME1}  ${PASSWORD}  0
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login    ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    
    Set Suite Variable  ${BH}   ${decrypted_data['id']}
    Set Test Variable   ${lic_id}         ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200

    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable RBAC    ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings        ${resp1.status_code}  200
    END

    IF  ${resp.json()['enableCdl']}==${bool[0]}
        ${resp1}=  Enable Disable CDL  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings        ${resp1.status_code}  200
    END

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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings            ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length               ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable                 ${user_phone}         ${resp.json()[${i}]['mobileNo']}
    END

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
    Set Suite Variable  ${BM_USERNAME}     ${resp.json()['mobileNo']}

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
    Set Suite Variable  ${state}     ${resp.json()[0]['PostOffice'][0]['State']}    
    Set Suite Variable  ${district}  ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${pin}       ${resp.json()[0]['PostOffice'][0]['Pincode']}
    
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

    ${resp}=  SendProviderResetMail        ${SO_USERNAME}
    Should Be Equal As Strings             ${resp.status_code}   200

    ${resp}=  ResetProviderPassword        ${SO_USERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings             ${resp[0].status_code}   200
    Should Be Equal As Strings             ${resp[1].status_code}   200

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

# ....... Dealer shop photo .......

    ${resp}=  db.getType                   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary     ${resp}    ${pngfile}
    Set Suite Variable   ${fileType2}
    ${caption2}=                           Fakerlibrary.Sentence
    Set Suite Variable   ${caption2}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${pngfile}    ${fileSize}    ${caption2}    ${fileType2}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}             ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file   ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Dealer adhaar attachment .......

    ${resp}=  db.getType                   ${pdffile}
    Log  ${resp}
    ${fileType3}=  Get From Dictionary     ${resp}    ${pdffile}
    Set Suite Variable   ${fileType3}
    ${caption3}=                           Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}        ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file  ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Dealer PAN attachment .......

    ${resp}=  db.getType                   ${jpgfile2}
    Log  ${resp}
    ${fileType4}=  Get From Dictionary     ${resp}    ${jpgfile2}
    Set Suite Variable  ${fileType4}
    ${caption4}=                           Fakerlibrary.Sentence
    Set Suite Variable  ${caption4}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${jpgfile2}    ${fileSize}    ${caption4}    ${fileType4}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Pan Verify .......

    ${pan}   Random Number  digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable                     ${pan}  55555${pan}

    ${resp}=                               Update Partner Pan  ${pan}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${jpgfile2}    ${fileSize}    ${caption4}    ${fileType4}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Dealer cheque/passbok attachment .......

    ${resp}=  db.getType                   ${pdffile}
    Log  ${resp}
    ${fileType3}=  Get From Dictionary     ${resp}    ${pdffile}
    Set Suite Variable   ${fileType3}
    ${caption3}=                           Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Validate GST .......

    ${gstin}  Random Number 	digits=5 
    ${gstin}=   Evaluate   f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable                     ${gstin}  55555${gstin}

    ${resp}=    Validate Gst               ${partuid1}  ${gstin}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Dealer gst attachment.......

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Dealer agreement .......

    ${resp}=  db.getType                   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary     ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${partid1}    ${ownerType[0]}    ${dealerfname}    ${pngfile}    ${fileSize}    ${caption2}    ${fileType2}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Verify Partner Bank .......

    ${bankAccountNo}                       Random Number 	digits=5 
    ${bankAccountNo}=                      Evaluate   f'{${bankAccountNo}:0>7d}'
    Log  ${bankAccountNo}
    Set Suite Variable   ${bankAccountNo}  55555${bankAccountNo}
    ${bankIfsc}                            Random Number 	digits=5 
    ${bankIfsc}=                           Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable                     ${bankIfsc}  55555${bankIfsc}  
    ${bankName}                            FakerLibrary.name
    Set Suite Variable   ${bankName}

    ${resp}    Verify Partner Bank         ${partid1}    ${partuid1}     ${bankAccountNo}    ${bankIfsc}     bankName=${bankName}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}    Update Partner Bank         ${bankAccountNo}    ${bankIfsc}    ${bankName}    ${partuid1}    ${LoanAction[0]}    ${partid1}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 

# ....... Partner Details .......

    ${aadhaarAttachments}=                 Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption3}  fileType=${fileType3}  order=${order}
    ${aadhaarAttachments}=                 Create List  ${aadhaarAttachments}

    ${panAttachments}=                     Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}
    ${panAttachments}=                     Create List  ${panAttachments}

    ${gstAttachments}=                     Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    ${gstAttachments}=                     Create List  ${gstAttachments}

    ${licenceAttachments}=                 Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${jpgfile2}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${licenceAttachments}=                 Create List  ${licenceAttachments}

    ${partnerAttachments}=                 Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${gif}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${partnerAttachments}=                 Create List  ${partnerAttachments}

    ${storeAttachments}=                   Create Dictionary   action=${LoanAction[0]}  owner=${partid1}  fileName=${xlsx}  fileSize=${fileSize}  caption=${caption4}  fileType=${fileType4}  order=${order}
    ${storeAttachments}=                   Create List  ${storeAttachments}

    ${description}=                        FakerLibrary.sentence
    ${partnerCity}=                        FakerLibrary.city
    ${partnerAliasName}                    FakerLibrary.name

    ${resp}=    Partner Details            ${partuid1}    ${dealername}    ${phone}    ${email}    ${description}     ${Ptypeid}    ${Pcategoryid}    ${address1}    ${address2}    ${pin}    ${partnerCity}    ${district}    ${state}    ${aadhaar}    ${pan}    ${gstin}    ${branch}    ${partnerAliasName}    ${aadhaarAttachments}    ${panAttachments}    ${gstAttachments}    ${licenceAttachments}    ${partnerAttachments}    ${storeAttachments}   
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 

# ....... Approval Request .......

    ${resp}=   Partner Approval Request    ${partuid1}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# .....Approve Dealer By Branch Manager......

    ${resp}=  SendProviderResetMail        ${BM_USERNAME}
    Should Be Equal As Strings             ${resp.status_code}      200

    @{resp}=  ResetProviderPassword        ${BM_USERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings             ${resp[0].status_code}   200
    Should Be Equal As Strings             ${resp[1].status_code}   200

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${note}=                               FakerLibrary.sentence
    Set Suite Variable   ${note}

    ${resp}=   Partner Approved            ${partuid1}              ${note}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}      200

# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=  Create Dictionary    id=${SO}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer       ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${Creditofficer}=  Create Dictionary   id=${BCH}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer      ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=    Activate Partner           ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Login Sales Office and Create Lead .......

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${cust}    Random Number  digits=5 
    ${cust}=   Evaluate  f'{${cust}:0>7d}'
    Log  ${cust}
    Set Suite Variable                     ${cust}  555${cust}

    ${fname}=                              FakerLibrary.name
    ${lname}=                              FakerLibrary.name
    
    ${resp}=  GetCustomer                  phoneNo-eq=${cust}  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${cust}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings         ${resp1.status_code}    200
        Set Suite Variable  ${cust_id}      ${resp1.json()}
    ELSE
        Set Suite Variable  ${cust_id}      ${resp.json()[0]['id']}
    END

    Set Suite Variable  ${cust_email}           ${fname}${C_Email}.ynwtest@jaldee.com
    ${cust_email}=    String.RemoveString       ${cust_email}    ${SPACE}

    updateEnquiryStatus                    ${account_id1}
    sleep  01s
    ${resp}=  categorytype                 ${account_id1}
    ${resp}=  tasktype                     ${account_id1}

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    ${en_catagories}=  Set Variable        ${resp.json()}
    ${random_catagories}=  Evaluate        random.choice($en_catagories)  random
    ${rand_catagory_id}=  Set Variable     ${random_catagories['id']}
    ${rand_catagory_name}=  Set Variable   ${random_catagories['name']}

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    ${en_cat_types}=  Set Variable         ${resp.json()}
    ${random_cat_types}=  Evaluate         random.choice($en_cat_types)  random
    ${rand_cat_type_id}=  Set Variable     ${random_cat_types['id']}
    ${rand_cat_type_name}=  Set Variable   ${random_cat_types['name']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF   '${resp.json()[${i}]['name']}' == 'Follow Up'

            Set Test Variable              ${enq_sts_new_id}    ${resp.json()[${i}]['id']}
            Set Test Variable              ${enq_sts_new_name}  ${resp.json()[${i}]['name']}

        END
    END

    ${en_temp_name}=    FakerLibrary.name

    enquiryTemplate                        ${account_id1}  ${en_temp_name}  ${enq_sts_new_id}  category_id=${rand_catagory_id}  type_id=${rand_cat_type_id}  creator_provider_id=${SO} 

    ${resp}=  Get Enquiry Template  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    Set Test Variable  ${en_temp_id}       ${resp.json()[0]['id']}

    ${title}=  FakerLibrary.Job
    ${desc}=   FakerLibrary.City
    ${category}=  Create Dictionary        id=${rand_catagory_id}
    ${type}=  Create Dictionary            id=${rand_cat_type_id}
    ${pan2}   Random Number  digits=5 
    ${pan2}=    Evaluate    f'{${pan2}:0>5d}'
    Log  ${pan2}
    Set Suite Variable                     ${pan2}  55555${pan2}

    ${resp}=  Create CDL Enquiry           ${category}  ${cust_id}  ${city}  ${aadhaar}  ${pan2}  ${state}  ${pin}  ${locId}  ${en_temp_id}  ${minAmount} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    Set Suite Variable                     ${en_id}                ${resp.json()['id']}
    Set Suite Variable                     ${en_uid}               ${resp.json()['uid']}

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Test Variable                  ${status_id${i}}        ${resp.json()[${i}]['id']}
        Set Test Variable                  ${status_name${i}}      ${resp.json()[${i}]['name']}
    END

    ${resp}=  Get Enquiry by Uuid          ${en_uid}  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    Should Be Equal As Strings             ${resp.json()['id']}    ${en_id}
    Should Be Equal As Strings             ${resp.json()['uid']}   ${en_uid}

# ....... Create Loan - Generate and verify phone for loan.......
    
    ${resp}=                               Generate Loan Application Otp for Phone Number    ${cust}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${gender}    Random Element            ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth    minimum_age=23   maximum_age=55
    ${dob}=  Convert To String             ${dob} 
    ${kyc_list1}=  Create Dictionary       isCoApplicant=${bool[0]}

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id}  ${locId}   ${kyc_list1}  firstName=${fname}  lastName=${lname}  phoneNo=${cust}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Set Suite VAriable                     ${loanid}              ${resp.json()['id']}
    Set Suite VAriable                     ${loanuid}             ${resp.json()['uid']}

# ....... Generate and verify email for loan .......

    ${resp}=                               Generate Loan Application Otp for Email  ${cust_email}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=    Verify Email Otp and Create Loan Application  ${cust_email}  ${OtpPurpose['ConsumerVerifyEmail']}  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${datetime1}    ${resp.json()}   
    ${datetime01}    Convert Date    ${datetime1}    result_format=%Y-%m-%d %H:%M

    ${resp}=                               Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Set Test Variable                      ${kycid}               ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable                     ${ref_no}              ${resp.json()['referenceNo']}
    Run Keyword And Continue On Failure    Should Contain                         ${resp.json()["lastStatusUpdatedDate"]}    ${datetime01}


# ....... Customer Photo .......

    ${resp}=  db.getType                   ${pngfile}
    Log  ${resp}
    ${fileType2}=  Get From Dictionary     ${resp}    ${pngfile}
    Set Suite Variable    ${fileType2}
    ${caption2}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption2}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${cust_id}    ${ownerType[0]}    ${dealerfname}    ${pngfile}    ${fileSize}    ${caption2}    ${fileType2}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Test Variable                      ${driveId}    ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... Save Customer Details .......

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${datetime2}    ${resp.json()} 
    ${datetime02}    Convert Date    ${datetime2}    result_format=%Y-%m-%d %H:%M

    ${resp}=  Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Set Test Variable                      ${kycid}               ${resp.json()["loanApplicationKycList"][0]["id"]}
    Run Keyword And Continue On Failure    Should Contain             ${resp.json()["lastStatusUpdatedDate"]}    ${datetime02}

    ${CustomerPhoto}=  Create Dictionary   action=${LoanAction[0]}    owner=${cust_id}  fileName=${pngfile}  fileSize=${fileSize}  caption=${caption2}  fileType=${fileType2}  order=${order}    driveId=${driveId}   ownerType=${ownerType[0]}   type=photo
    Log  ${CustomerPhoto}

    ${locations}=    Create Dictionary     id=${locId}
    ${kyc_list_cust}=  Create Dictionary   isCoApplicant=${boolean[0]}   id=${kycid}

    ${resp}=    Save Customer Details      ${loanuid}  ${fname}  ${lname}  ${cust_email}  ${dob}  ${gender}  ${cust_id}  ${kyc_list_cust}  ${locations}    ${CustomerPhoto}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

# ....... CUstomer adhaar attachment .......

    ${resp}=  db.getType                   ${pdffile}
    Log  ${resp}
    ${fileType3}=  Get From Dictionary     ${resp}    ${pdffile}
    Set Suite Variable   ${fileType3}
    ${caption3}=                           Fakerlibrary.Sentence
    Set Suite Variable   ${caption3}

    ${resp}                                upload file to temporary location    ${file_action[0]}    ${cust_id}    ${ownerType[0]}    ${dealerfname}    ${pdffile}    ${fileSize}    ${caption3}    ${fileType3}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200 
    Set Suite Variable                      ${driveId2}        ${resp.json()[0]['driveId']}

    ${resp}                                change status of the uploaded file  ${QnrStatus[1]}    ${driveId2}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${datetime3}    ${resp.json()} 
    ${datetime03}    Convert Date    ${datetime3}    result_format=%Y-%m-%d %H:%M

    ${resp}=  Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Run Keyword And Continue On Failure    Should Contain             ${resp.json()["lastStatusUpdatedDate"]}    ${datetime03}
    

# ....... Verify adhaar number .......

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${cust_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo
    Log  ${aadhaarAttachment}
    Set Suite Variable      ${aadhaarAttachment}

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH1
                                  
    [Documentation]               requst for aadhar validation - whcich is already validated

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH2
                                  
    [Documentation]               requst for aadhar validation - where id is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${empty}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200


JD-TC-RequstForAadharValidation-UH3
                                  
    [Documentation]               requst for aadhar validation - where id is invalid

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${fake}=    FakerLibrary.Random Number

    ${resp}=                               Requst For Aadhar Validation    ${fake}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200


JD-TC-RequstForAadharValidation-Uh4
                                  
    [Documentation]               requst for aadhar validation - uid is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${empty}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${INVALID_KYC_ID}

JD-TC-RequstForAadharValidation-Uh5
                                  
    [Documentation]               requst for aadhar validation - where uid is invalid

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${fake}=    FakerLibrary.Random Number

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${fake}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${INVALID_KYC_ID}

JD-TC-RequstForAadharValidation-Uh6
                                  
    [Documentation]               requst for aadhar validation - where phone is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${empty}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${INVALID_KYC_ID}

JD-TC-RequstForAadharValidation-Uh7
                                  
    [Documentation]               requst for aadhar validation - where phone is invalid

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${fake}=    FakerLibrary.Random Number

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${fake}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${INVALID_KYC_ID}

JD-TC-RequstForAadharValidation-UH8
                                  
    [Documentation]               requst for aadhar validation - whcich is already validated

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH9
                                  
    [Documentation]               requst for aadhar validation - where aadhar is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${empty}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${AADHAR_NUMBER_REQUIRED}

JD-TC-RequstForAadharValidation-UH10
                                  
    [Documentation]               requst for aadhar validation - where aadhar is invalid

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${fake} =       FakerLibrary.Random Number

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${fake}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${ENTER_VALID_AADHAR_NUMBER}

JD-TC-RequstForAadharValidation-UH11
                                  
    [Documentation]               requst for aadhar validation - where action in remove

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[1]}  owner=${cust_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=  Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH12
                                  
    [Documentation]               requst for aadhar validation - where owner is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${empty}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH13
                                  
    [Documentation]               requst for aadhar validation - where owner is invalid

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${fake}=    FakerLibrary.Random Number

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${fake}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH14
                                  
    [Documentation]               requst for aadhar validation - where file name is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${cust_id}  fileName=${empty}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}    ${FILE_NAME_NOT_FOUND}

JD-TC-RequstForAadharValidation-UH15
                                  
    [Documentation]               requst for aadhar validation - where file size is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${cust_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH16
                                  
    [Documentation]               requst for aadhar validation - where caption is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${cust_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

JD-TC-RequstForAadharValidation-UH17
                                  
    [Documentation]               requst for aadhar validation - where file type is empty

    ${resp}=  Encrypted Provider Login     ${BM_USERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}      200

    ${aadhaarAttachment}=                 Create Dictionary   action=${LoanAction[0]}  owner=${cust_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${empty}  order=${order}   driveId=${driveId2}   ownerType=${ownerType[0]}   type=photo

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${FILE_TYPE_NOT_FOUND}

JD-TC-RequstForAadharValidation-UH18
                                  
    [Documentation]               requst for aadhar validation - whithout login

    ${resp}=                               Requst For Aadhar Validation    ${cust_id}    ${loanuid}    ${cust}    ${aadhaar}    ${aadhaarAttachment}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}
