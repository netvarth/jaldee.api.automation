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
        ${decrypted_data}=  db.decrypt_data   ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${pkgId}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
        Set Test Variable  ${Dom}   ${decrypted_data['sector']}
        Set Test Variable  ${SubDom}   ${decrypted_data['subSector']}
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
   
    [Return]  ${MUSERNAME${a}}



*** Test Cases ***

JD-TC-RBAC-CDL-1
 
 
    [Documentation]  sales officer creates loan for new provider customer and check the loan can be viewed by branch credit head

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

    ${NBFCMUSERNAME1}=  Evaluate  ${MUSERNAME}+8745922
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

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login    ${NBFCMUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${userids}=  Create List  ${so_id}   ${co1_id}    ${account_id}
    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users    ${userids}  ${branch1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    
    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${consumernumber}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${Custfname}    ${Custlname}    ${consumernumber}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${consumernumber}
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${Custfname}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${Custlname}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
    Set Test Variable  ${custid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application With Filter  spInternalStatus-eq=${LoanApplicationSpInternalStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}  ${loanuid}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}  ${custid}
    Should Be Equal As Strings  ${resp.json()[0]['spInternalStatus']}  ${LoanApplicationSpInternalStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['applicationStatus']}  ${LoanApplicationStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['generatedBy']}  ${so_proid}
    Should Be Equal As Strings  ${resp.json()[0]['generatedByName']}  ${pro_name}
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}  ${locId}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${User2_CO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()['uid']}  ${loanuid}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}  ${custid}
    Should Be Equal As Strings  ${resp.json()['spInternalStatus']}  ${LoanApplicationSpInternalStatus[0]}
    Should Be Equal As Strings  ${resp.json()['applicationStatus']}  ${LoanApplicationStatus[0]}
    Should Be Equal As Strings  ${resp.json()['generatedBy']}  ${so_proid}
    Should Be Equal As Strings  ${resp.json()['generatedByName']}  ${pro_name}
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${locId}

    ${resp}=  Encrypted Provider Login  ${User3_CO2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}  ${emptylist}


JD-TC-RBAC-CDL-2
 
    [Documentation]  Sales officer creates loan for existing provider customer with full details and check if branch credit head can view it.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${address}=  FakerLibrary.address
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        ${resp1}=  AddCustomer  ${consumernumber}  firstName=${Custfname}  lastName=${Custlname}  address=${address}  gender=${gender}  dob=${dob} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${custid}   ${resp1.json()}
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${consumernumber}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()['uid']}  ${loanuid}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}  ${custid}

    ${resp}=    Get Loan Application With Filter  spInternalStatus-eq=${LoanApplicationSpInternalStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}  ${loanuid}

    ${resp}=  Encrypted Provider Login  ${User2_CO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()['uid']}  ${loanuid}

    ${resp}=  Encrypted Provider Login  ${User3_CO2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-RBAC-CDL-3
 
    [Documentation]  Sales officer creates loan for existing provider customer without full details and check if branch credit head can view it.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${address}=  FakerLibrary.address
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        ${resp1}=  AddCustomer  ${consumernumber}  firstName=${Custfname}  lastName=${Custlname} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${custid}   ${resp1.json()}
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${consumernumber}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()['uid']}  ${loanuid}
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id}
    Should Be Equal As Strings  ${resp.json()['customer']['id']}  ${custid}

    ${resp}=    Get Loan Application With Filter  spInternalStatus-eq=${LoanApplicationSpInternalStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()[0]['uid']}  ${loanuid}

    ${resp}=  Encrypted Provider Login  ${User2_CO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}
    Should Be Equal As Strings  ${resp.json()['uid']}  ${loanuid}

    ${resp}=  Encrypted Provider Login  ${User3_CO2}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


JD-TC-RBAC-CDL-UH1
 
    [Documentation]  Sales officer creates loan for new provider customer without gender.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${VAL_GENDER}
    

JD-TC-RBAC-CDL-UH2
 
    [Documentation]  Sales officer creates loan for new provider customer without dob.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${DOB_INVALID}


JD-TC-RBAC-CDL-UH3
 
    [Documentation]  Sales officer creates loan for new provider customer without firstname.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${ENTER_FIRST_NAME}


JD-TC-RBAC-CDL-UH4
 
    [Documentation]  Sales officer creates loan for new provider customer without lastname.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${PROVIDE_LAST_NAME}


JD-TC-RBAC-CDL-UH5
 
    [Documentation]  Sales officer creates loan for new provider customer without phone number.

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
    ELSE
        Set Test Variable  ${custid}  ${resp.json()[0]['id']}
    END

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}   ${PHONE_NUMBER_REQUIRED}

JD-TC-RBAC-CDL-2
 
    [Documentation]  create loan by partner and assign to sales_officer and View the loan

    ${resp}=  Encrypted Provider Login  ${User1_SO}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${so_proid}  ${decrypted_data['id']}
    Set Test Variable  ${pro_name}  ${decrypted_data['userName']}

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable  ${locId}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${partnernum}  555${PH_Number}
    
    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}
    ${partName}=  FakerLibrary.bs
    ${partAlName}=  FakerLibrary.Company
    ${partFname}=  FakerLibrary.First Name
    ${partLname}=  FakerLibrary.Last Name

    ${resp}=  Generate Phone Partner Creation    ${partnernum}    ${countryCodes[0]}  partnerName=${partName}   partnerUserFirstName=${partFname}  partnerUserLastName=${partLname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=  Create Dictionary  id=${branchid1}

    
    ${resp}=  Verify Phone Partner Creation  ${partnernum}  ${OtpPurpose['ProviderVerifyPhone']}  ${partName}   ${partAlName}  branch=${branch}  partnerUserName=${partFname}  partnerUserFirstName=${partFname}  partnerUserLastName=${partLname}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid}  ${resp.json()['id']}
    Set Suite Variable  ${partuid}  ${resp.json()['uid']} 

    ${resp}=    Get Partner by UID    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    # Set Test Variable  ${email}  ${partnernum}${partownername}.${test_mail}
    Set Test Variable  ${email}  ${partownername}.${test_mail}

    ${resp}=    Generate OTP for partner Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify OTP for Partner Email    ${email}  ${partid}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Approval Request    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${User5_BOH}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}
    ${resp}=   Partner Approved    ${partuid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        IF  ${resp.json()[${i}]['mobileNo']}==${User2_CO}
            Set Test Variable  ${co1_id}  ${resp.json()[${i}]['id']}
        END
    END
    
    ${Salesofficer}=    Create Dictionary    id=${so_proid}   name=${pro_name}    isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${co1_id}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Partner by UID    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Partner Reset Password    ${account_id}  ${partnernum}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    511 
    Should Be Equal As Strings   ${resp.json()}   otp authentication needed
    # Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Verify Otp For Login Partner  ${partnernum}  ${OtpPurpose['Authentication']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Complete Partner Reset Password    ${account_id}  ${partnernum}  ${PASSWORD}  ${token}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Login Partner with Password    ${account_id}  ${partnernum}  ${PASSWORD}
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
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
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

    ${resp}=  Get Partner Loan Application Consumer Details with filter  phoneNo-eq=${consnum}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${consnum}

    ${resp}=  Get Partner Loan Application By uid   ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${loanid}

    # ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${ifsc_code}=   db.Generate_ifsc_code
    ${bank_ac}=   db.Generate_random_value  size=8   chars=${digits} 
    ${bank_ac}    Convert To Integer  ${bank_ac}
    ${acc_no}=    Evaluate    f'{${bank_ac}:5>11d}'
    Log  ${acc_no}
    # Set Suite Variable  ${partnernum}  555${PH_Number}
    ${bank_name}=  FakerLibrary.company
    ${name}=  FakerLibrary.name
    ${branch}=   db.get_place

    ${aadhar}    Random Number 	digits=8  fix_len=True
    ${aadhar}    Convert To Integer  ${aadhar}
    ${aadhar_num}=    Evaluate    f'{${aadhar}:5>12d}'
    Log  ${aadhar_num}
    

    





    

***Comment***


JD-TC-Cases-2
 
    [Documentation]  create loan by partner and assignee to sales_officer and View the loan
    
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}

    ${note}=    FakerLibrary.Sentence
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}    branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    Set Suite Variable  ${partuid}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Identify Partner    ${phone}    ${account_id}    ${id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Verify Otp For Login Partner    ${phone}  12
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Partner Login    ${phone}    ${account_id}    ${token}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings     ${resp.json()['id']}   ${id1} 
    Should Be Equal As Strings     ${resp.json()['primaryPhoneNumber']}   ${phone}

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Partner Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=   Get Partner Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Partner Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']}    

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Partner Verify Otp for phone   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Partner Otp For Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Verify Otp for Email    ${email}    5    ${loanuid}
    Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Partner Aadhar Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Partner loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

    ${resp}=    Verify Partner loan Bank   ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role7}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles7}=  Create List   ${role7}

    ${PUSERNAME_U5}=  Evaluate  ${PUSERNAME}+3766708
    clear_users  ${PUSERNAME_U5}
    Set Suite Variable  ${PUSERNAME_U5}

    ${whpnum}=  Evaluate  ${PUSERNAME}+449973
    ${tlgnum}=  Evaluate  ${PUSERNAME}+447913

    ${resp}=  Create User With Roles And Scope  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  
    ...   ${P_Email}${PUSERNAME_U5}.${test_mail}   ${userType[0]}  ${pin}  
    ...   ${countryCodes[1]}  ${PUSERNAME_U5}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[1]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}  ${user_roles7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sales_officer}  ${resp.json()}

    ${resp}=  Get User By Id  ${sales_officer}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Change Loan Assignee        ${loanUid}    ${sales_officer}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['assignee']['id']}  ${sales_officer}

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U5}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U5}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['assignee']['id']}  ${sales_officer}
   
    ${resp}=  Provider Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    
JD-TC-Cases-3
 
 
    [Documentation]   create loan by partner and assignee to  branch credit head and View the loan
    
    ${resp}=  Consumer Login  ${CUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END
   
    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}

    ${note}=    FakerLibrary.Sentence
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}


    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}     branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    Set Suite Variable  ${partuid}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Identify Partner    ${phone}    ${account_id}    ${id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Verify Otp For Login Partner    ${phone}  12
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Partner Login    ${phone}    ${account_id}    ${token}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings     ${resp.json()['id']}   ${id1} 
    Should Be Equal As Strings     ${resp.json()['primaryPhoneNumber']}   ${phone}

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Partner Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=   Get Partner Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Partner Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']}    

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Partner Verify Otp for phone   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Partner Otp For Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Verify Otp for Email    ${email}    5    ${loanuid}
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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Partner Aadhar Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${pcid14}    ${loanuid}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update Partner loan Bank Details    4    ${loanuid}    ${loanuid}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Partner loan Bank Details    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}


    ${resp}=    Verify Partner loan Bank   ${loanuid}    ${bankName}    ${bankAccountNo}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

   
    
    ${role5}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles5}=  Create List   ${role5}
   

    ${PUSERNAME_U6}=  Evaluate  ${PUSERNAME}+3766764
    clear_users  ${PUSERNAME_U6}
    Set Suite Variable  ${PUSERNAME_U6}

    ${whpnum1}=  Evaluate  ${PUSERNAME}+449974
    ${tlgnum1}=  Evaluate  ${PUSERNAME}+447919


    ${resp}=  Create User With Roles And Scope  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  
    ...   ${P_Email}${PUSERNAME_U6}.${test_mail}   ${userType[0]}  ${pin}  
    ...   ${countryCodes[1]}  ${PUSERNAME_U6}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  
    ...   ${countryCodes[1]}  ${whpnum1}  ${countryCodes[0]}  ${tlgnum1}  ${user_roles5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Branch_Credithead}  ${resp.json()}

    
    ${resp}=    Change Loan Assignee        ${loanUid}    ${Branch_Credithead}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['assignee']['id']}  ${Branch_Credithead}

   
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U6}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U6}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${account_id}  ${resp.json()['id']}
  
    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['assignee']['id']}  ${Branch_Credithead}
   
    ${resp}=  Provider Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

JD-TC-Case-5
 
 
    [Documentation]   create loan by partner and view the loan by
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END
    ${PUSERNAME_U10}=  Evaluate  ${PUSERNAME}+558467
    clear_users  ${PUSERNAME_U10}
    Set Suite Variable  ${PUSERNAME_U10}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U10}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U10}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branch_credithead}  ${resp.json()}

    ${resp}=  Get User By Id  ${branch_credithead}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${firstName}    ${resp.json()['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()['mobileNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role2}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List      ${role2}

    ${user_ids}=  Create List     ${branch_credithead}


    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${PUSERNAME_U7}=  Evaluate  ${PUSERNAME}+5584578
    clear_users  ${PUSERNAME_U7}
    Set Suite Variable  ${PUSERNAME_U7}

    # ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    # ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U7}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U7}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${firstName}    ${resp.json()['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()['mobileNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}
 

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U10}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U10}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U7}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U7}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    

    ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}

    ${note}=    FakerLibrary.Sentence
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    # ${user_ids}=  Create List   ${u_id1}  

    # ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
   
    ${branch}=      Create Dictionary   id=${branchid1}


    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}     branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid}  ${resp.json()['id']}
    Set Suite Variable  ${partuid}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${partuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${partuid}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Identify Partner    ${phone}    ${account_id}    ${id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Verify Otp For Login Partner    ${phone}  12
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Partner Login    ${phone}    ${account_id}    ${token}   
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    # Should Be Equal As Strings     ${resp.json()['id']}   ${id1} 
    Should Be Equal As Strings     ${resp.json()['primaryPhoneNumber']}   ${phone}

   

    # ${resp}=  Run Keyword If  ${resp.json()['enableRbac']}==${bool[0]}   Enable Disable RBAC partner  ${toggle[0]}
    # Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    # Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Enable Disable CDL partner   ${toggle[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200


    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

    ${resp}=    Get Partner Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${categoryname}  ${resp.json()[0]['name']}

    ${resp}=   Get Partner Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${typename}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${statusname}  ${resp.json()[0]['name']}

    ${resp}=    Get Partner Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${productname}  ${resp.json()[0]['productName']}

    ${resp}=    Get Partner Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']}    

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Partner Verify Otp for phone   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid5}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid5}    ${resp.json()['uid']}

    ${resp}=    Partner Otp For Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Partner Verify Otp for Email    ${email}    5    ${loanuid}
    Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Partner Aadhar Validation    ${pcid14}    ${loanuid5}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Partner Pan Validation    ${pcid14}    ${loanuid5}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankName}    FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add Partner loan Bank Details    4    ${loanuid5}    ${loanuid5}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update Partner loan Bank Details    4    ${loanuid5}    ${loanuid5}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    ${resp}=    Get Partner loan Bank Details    ${loanuid5}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}


    ${resp}=    Verify Partner loan Bank   ${loanuid5}    ${bankName}    ${bankAccountNo}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Logout 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

   
    ${partners_id}=  Create List    ${partid}
    ${user_scope}=  Create Dictionary    partners=${partners_id} 
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary    defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    
    ${PUSERNAME_U8}=  Evaluate  ${PUSERNAME}+558643
    clear_users  ${PUSERNAME_U8}
    Set Suite Variable  ${PUSERNAME_U8}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U8}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U8}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${user_ids}=  Create List   ${u_id3}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    # Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    # Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    # Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    # Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}
   

    ${user_scope}=  Create Dictionary     
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

  
    ${PUSERNAME_U9}=  Evaluate  ${PUSERNAME}+5586467
    clear_users  ${PUSERNAME_U9}
    Set Suite Variable  ${PUSERNAME_U9}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U9}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U9}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id9}  ${resp.json()}

    # ${user_ids}=  Create List   ${u_id9}  

    # ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


   
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U9}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U9}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U8}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U8}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Loan Application By uid  ${loanuid5} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${loanid5}
    Should Be Equal As Strings    ${resp.json()['uid']}    ${loanuid5}
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerFirstName']}    ${firstName}  
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerLastName']}    ${lastName}    
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerPhone']}    ${phoneNo}
    
   
    ${resp}=  Provider Logout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Partner by UID    ${partuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings   ${resp.json()["id"]}   ${partid}
    Should Be Equal As Strings   ${resp.json()["uid"]}   ${partuid}

    
    ${resp}=    Get Loan Application By uid  ${loanuid5} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${loanid5}
    Should Be Equal As Strings    ${resp.json()['uid']}    ${loanuid5}
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerFirstName']}    ${firstName}  
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerLastName']}    ${lastName}    
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerPhone']}    ${phoneNo}
    
   
JD-TC-Case-6
 
 
    [Documentation]   create loan by partner and view Partner with another user . the another user gave partner id in user scope
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${partners_id}=  Create List    ${partid}
    ${user_scope}=  Create Dictionary    partners=${partners_id} 
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary     defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    
    ${PUSERNAME_U8}=  Evaluate  ${PUSERNAME}+5586432
    clear_users  ${PUSERNAME_U8}
    Set Suite Variable  ${PUSERNAME_U8}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458799
    ${tlgnum}=  Evaluate  ${PUSERNAME}+456698

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U8}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U8}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${user_ids}=  Create List   ${u_id3}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
   
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U8}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U8}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Partner by UID    ${partuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings   ${resp.json()["id"]}   ${partid}
    Should Be Equal As Strings   ${resp.json()["uid"]}   ${partuid}

JD-TC-Case-7
 
 
    [Documentation]   create loan by partner and view Partner with another user . the another user gave partner id in user scope
  
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Partner by UID    ${partuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Should Be Equal As Strings   ${resp.json()["id"]}   ${partid}
    Should Be Equal As Strings   ${resp.json()["uid"]}   ${partuid}

JD-TC-Case-8
 
 
    [Documentation]   create loan by partner and view Partner with another user . the another user gave partner id in user scope
  

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+5563
    clear_users  ${PUSERNAME_U3}
    Set Suite Variable  ${PUSERNAME_U3}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U3}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}

    ${location_id}=  Create List    ${locId}
    ${branches_id}=  Create List    ${branchid1}
    # ${users_id}=  Create List      all
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}   


    ${user_ids}=  Create List   ${u_id3}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+789586
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
   
    ${resp}=  Create User    ${lastname}  ${firstname}    ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[1]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${PUSERNAME_U10}=  Evaluate  ${PUSERNAME}+61398467
    clear_users  ${PUSERNAME_U10}
    Set Suite Variable  ${PUSERNAME_U10}

    ${whpnum}=  Evaluate  ${PUSERNAME}+458792
    ${tlgnum}=  Evaluate  ${PUSERNAME}+845962

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U10}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U10}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branch_credithead}  ${resp.json()}

    ${resp}=  Get User By Id  ${branch_credithead}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${firstName}    ${resp.json()['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()['mobileNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role2}=  Create Dictionary   id=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List      ${role2}

    ${user_ids}=  Create List     ${branch_credithead}


    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
   
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U10}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U10}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${PO_Number}=  Generate Random Phone Number
    ${phone}=  Convert To Integer    ${PO_Number}

    ${note}=    FakerLibrary.Sentence
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${phone}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${phone}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${fname}${C_Email}.${test_mail}

    
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

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 
    Set Suite Variable  ${Schemename1}  ${resp.json()[1]['schemeName']} 
    Set Suite Variable  ${Schemename2}  ${resp.json()[2]['schemeName']} 

    ${resp}=  Get Loan Application SP Internal Status   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${len}
        Set Suite Variable  ${sp_status_id${i}}    ${resp.json()[${i}]['id']}
        Set Suite Variable  ${sp_status_name${i}}  ${resp.json()[${i}]['name']}
    END

    ${resp}=  Generate Phone Partner Creation    ${phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id1}  ${resp.json()['id']}
    Set Suite Variable  ${uid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${uid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

   ${resp}=   Partner Approved    ${uid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Salesofficer}=    Create Dictionary    id=${u_id3}   name=${firstName}    isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${uid1}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${branch_credithead}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${uid1}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${uid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    sales officer verification    ${uid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid12}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid12}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid12} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}    

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid12}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid12} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# <----------------------------- KYC Details ------------------------------------------>

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${pcid14}    ${loanuid12}    ${phoneNo}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

      ${resp}=    Requst For Pan Validation    ${pcid14}    ${loanuid12}    ${phoneNo}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid12}     ${loanuid12}   ${phoneNo}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
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

    ${partner}=  Create Dictionary  id=${id1}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid12}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid12}    ${loanuid12}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${pcid14}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid12}    ${loanuid12}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid12}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid12}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid12}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid12}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_U10}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Loan Application Approval        ${loanuid12}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Loan Application By uid  ${loanuid12} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Loan Application By uid  ${loanuid12} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${loanid12}
    Should Be Equal As Strings    ${resp.json()['uid']}    ${loanuid12}
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerFirstName']}    ${firstName}  
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerLastName']}    ${lastName}    
    Should Be Equal As Strings    ${resp.json()['loanApplicationKycList'][0]['customerPhone']}    ${phoneNo}
    
