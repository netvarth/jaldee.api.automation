*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Api Gateway
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
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist}
${self}    0

${invoiceAmount}    60000
${downpaymentAmount}    2000
${requestedAmount}    58000
${sanctionedAmount}   58000

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pdffile}      /ebs/TDD/sample.pdf

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

*** Keywords ***

Account with Multiple Users in NBFC


    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    ${multiuser_list}=  Create List
    &{License_total}=  Create Dictionary
    ${licid}  ${licname}=  get_highest_license_pkg
    
    FOR   ${a}    IN RANGE   ${length}   
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
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
        Continue For Loop If  '${pkgId}' == '${licId}'

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF  ${resp.json()['metricUsageInfo'][8]['total']} > 2 and ${resp.json()['metricUsageInfo'][8]['used']} < ${resp.json()['metricUsageInfo'][8]['total']}
    Exit For Loop
        END
    END
   
    RETURN  ${PUSERNAME${a}}


*** Test Cases ***

JD-TC-GetLoanApplications-1

    [Documentation]   create a loan application by sales officer
    ...   branch1 and dealer1(credit approved status)
    ...   and check get loan applications with user token 
    
    ${NBFCPUSERNAME1}=  Account with Multiple Users in NBFC
    Log  ${NBFCPUSERNAME1}
    Set Suite Variable  ${NBFCPUSERNAME1}

    ${resp}=  Encrypted Provider Login  ${NBFCPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['isApiGateway']}==${bool[0]}
        ${resp1}=  Enable Disable API gateway  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get SP Token
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apiGateway']}   ${toggle[0]}
    Set Suite Variable    ${sp_token}   ${resp.json()['spToken']} 

# .... Create Loan ......

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

    ${resp}=  Get Default Roles With Capabilities  ${rbac_feature[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${role_id1}     ${resp.json()[0]['roleId']}
    Set Suite Variable  ${role_name1}   ${resp.json()[0]['displayName']}
    Set Suite Variable  ${capability1}  ${resp.json()[0]['capabilityList']}

    Set Suite Variable  ${role_id4}     ${resp.json()[3]['roleId']}
    Set Suite Variable  ${role_name4}   ${resp.json()[3]['displayName']}
    Set Suite Variable  ${capability4}  ${resp.json()[3]['capabilityList']}

    Set Suite Variable  ${role_id5}     ${resp.json()[4]['roleId']}
    Set Suite Variable  ${role_name5}   ${resp.json()[4]['displayName']}
    Set Suite Variable  ${capability5}  ${resp.json()[4]['capabilityList']}

    Set Suite Variable  ${role_id7}     ${resp.json()[6]['roleId']}
    Set Suite Variable  ${role_name7}   ${resp.json()[6]['displayName']}
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

    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${NBFCPUSERNAME1}'
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

    ${boh_id1}=  Create Sample User 
    Set Suite Variable  ${boh_id1}
    
    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BOHUSERNAME1}  ${resp.json()['mobileNo']}

    ${bco_id1}=  Create Sample User 
    Set Suite Variable  ${bco_id1}
    
    ${resp}=  Get User By Id  ${bco_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCOUSERNAME1}  ${resp.json()['mobileNo']}


# ....User  :Bussiness Head...

    ${location_id}=  Create List    all
    ${branches_id}=  Create List    all
    ${users_id}=  Create List    all

    ${user_scope}=  Create Dictionary   businessLocations=${location_id}  branches=${branches_id}   users=${users_id} 
    ${role1}=  Create Dictionary   roleId=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${provider_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${provider_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleId']}           ${role_id1}
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
    
    ${pin}=  get_pincode
    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${pin}
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
    
    ${pin1}=  get_pincode
    ${resp}=  Get LocationsByPincode     ${pin1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district1}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state1}=    Evaluate     "${state1}".title()
    ${state1}=    String.RemoveString  ${state1}    ${SPACE}

    ${resp}=    Create BranchMaster    ${branchCode1}    ${branchName1}    ${locId}    ${status[0]}    ${district1}    ${state1}    ${pin1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# .... Create Branch3....

    ${branchCode2}=    FakerLibrary.Random Number
    ${branchName2}=    FakerLibrary.name
    Set Suite Variable  ${branchName2}
    
    ${pin2}=  get_pincode
    ${resp}=  Get LocationsByPincode     ${pin2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district2}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state2}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state2}=    Evaluate     "${state2}".title()
    ${state2}=    String.RemoveString  ${state2}    ${SPACE}

   
    ${resp}=    Create BranchMaster    ${branchCode2}    ${branchName2}    ${locid1}    ${status[0]}    ${district2}    ${state2}    ${pin2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid3}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid3}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# ....User 1 :Sales Officer...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1}  ${branchid2}  ${branchid3}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}  
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   roleId=${role_id7}  roleName=${role_name7}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${so_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleId']}           ${role_id7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name7}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability7}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id7}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name7}


# ....User 3 :Branch Operation Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1}  ${branchid2}  ${branchid3}
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   roleId=${role_id4}  roleName=${role_name4}  defaultRole=${bool[1]}
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${boh_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${boh_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleId']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability4}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id4}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name4}


# ....User 4 :Branch Credit Head...

    ${location_id}=  Create List    ${locId}   ${locid1}
    ${branches_id}=  Create List    ${branchid1}  ${branchid2}  ${branchid3}
    ${users_id}=  Create List      ${so_id1}
    ${user_scope}=  Create Dictionary   businessLocations=${location_id}    branches=${branches_id}      users=${users_id}

    ${role1}=  Create Dictionary   roleId=${role_id5}  roleName=${role_name5}  defaultRole=${bool[1]}
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${bco_id1}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${bco_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleId']}           ${role_id5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name5}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability5}
   
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id5}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name5}


# .....Assigning branches to users

    ${userids}=  Create List  ${so_id1}   ${bco_id1}   ${boh_id1}
    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=${bool[0]}
    ${branch3}=  Create Dictionary   id=${branchid3}    isDefault=${bool[0]}

    ${resp}=  Assigning Branches to Users   ${userids}   ${branch1}  ${branch2}  ${branch3}  
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


# .....Create Dealer2 By Sales Officer.......

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone1}  555${PH_Number}

    ${resp}=  Generate Phone Partner Creation    ${phone1}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname1}=  FakerLibrary.name
    ${dealerlname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob} 
   
    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone1}   ${OtpPurpose['ProviderVerifyPhone']}   ${dealerfname1}   ${dealerlname1}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid2}  ${resp.json()['id']}
    Set Suite Variable  ${partuid2}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername2}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Create Dealer3 By Sales Officer.......

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone2}  555${PH_Number}

    ${resp}=  Generate Phone Partner Creation    ${phone2}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname2}=  FakerLibrary.name
    ${dealerlname2}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob} 
   
    ${branch}=      Create Dictionary   id=${branchid2}

    ${resp}=  Verify Phone Partner Creation    ${phone2}   ${OtpPurpose['ProviderVerifyPhone']}   ${dealerfname2}   ${dealerlname2}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid3}  ${resp.json()['id']}
    Set Suite Variable  ${partuid3}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername3}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Create Dealer4 By Sales Officer.......

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${phone3}  555${PH_Number}

    ${resp}=  Generate Phone Partner Creation    ${phone3}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${dealerfname3}=  FakerLibrary.name
    ${dealerlname3}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob} 
   
    ${branch}=      Create Dictionary   id=${branchid3}

    ${resp}=  Verify Phone Partner Creation    ${phone3}   ${OtpPurpose['ProviderVerifyPhone']}   ${dealerfname3}   ${dealerlname3}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${partid4}  ${resp.json()['id']}
    Set Suite Variable  ${partuid4}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${partnername4}  ${resp.json()[0]['partnerName']}

    ${resp}=   Partner Approval Request    ${partuid4}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# .....Approve Dealer1 By Branch Operation Head......

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

# .....Approve Dealer2 By Branch Operation Head......

    ${resp}=   Partner Approved    ${partuid2}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# .....Approve Dealer3 By Branch Operation Head......

    ${resp}=   Partner Approved    ${partuid3}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# .....Approve Dealer4 By Branch Operation Head......

    ${resp}=   Partner Approved    ${partuid4}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bco_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer2 & activate dealer2 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}   isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid2}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bco_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid2}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid2}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer3 & activate dealer3 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}   isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid3}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bco_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid3}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid3}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ...... Update sales officer and credit officer for dealer4 & activate dealer4 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}   isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${partuid4}        ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bco_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${partuid4}        ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${partuid4}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber}  555${PH_Number}
    
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

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
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

    ${resp}=    Verify loan Bank   ${loanuid}    ${bankAccountNo2}    ${bankIfsc}
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


    ${resp}=  SendProviderResetMail   ${BCOUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BCOUSERNAME1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BCOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#  .....Get Loan Applications Public APi call....

    ${resp}=   Create User Token   ${SOUSERNAME1}  ${PASSWORD}   ${sp_token}   ${countryCodes[0]}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${user_token}   ${resp.json()['userToken']} 

    ${resp}=  Get Loan Applications  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}


JD-TC-GetLoanApplications-2

    [Documentation]   create 2 loan applications by sales officer for different partners
    ...   branch1 and dealer2(credit approved)
    ...   and check get loan applications with user token 
  
    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber1}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber1}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=    Create Dictionary  isCoApplicant=${bool[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber1}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid1}   0
        ${Custfname1}=  FakerLibrary.name
        Set Suite Variable  ${Custfname1}
        ${Custlname1}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname1}
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob} 

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber1}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid1}  ${locId}  ${kyc_list1}  firstName=${Custfname1}  lastName=${Custlname1}  phoneNo=${consumernumber1}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite Variable  ${loanid1}    ${resp.json()['id']}
        Set Suite Variable  ${loanuid1}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber1}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid1}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid1}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname1}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname1}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber1}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid1}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid1}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid1}    ${resp.json()['uid']}

    END
   
    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid1}     ${resp.json()["loanApplicationKycList"][0]["id"]}
    Set Suite Variable  ${ref_no1}  ${resp.json()['referenceNo']} 

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid1}    ${loanuid1}    ${consumernumber1}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid1}    ${loanuid1}    ${consumernumber1}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid1}     ${loanuid1}   ${consumernumber1}       ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid1}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid2}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid1}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}  uid=${loanuid1}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid1}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid1}    ${loanuid1}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid1}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid1}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid1}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid1}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid1}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  Encrypted Provider Login  ${BCOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid1}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


#  .....Get Loan Applications Public APi call....

    ${resp}=  Get Loan Applications  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

JD-TC-GetLoanApplications-3

    [Documentation]   create a loan applications by sales officer in another branch
    ...   branch2 and dealer3(credit approved)
    ...   and check get loan applications with user token 

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${consumernumber2}  555${PH_Number}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber2}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=    Create Dictionary  isCoApplicant=${bool[0]}

    ${resp}=  GetCustomer  phoneNo-eq=${consumernumber2}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        Set Test Variable  ${custid2}   0
        ${Custfname2}=  FakerLibrary.name
        Set Suite Variable  ${Custfname2}
        ${Custlname2}=  FakerLibrary.last_name
        Set Suite Variable  ${Custlname2}
        ${gender}    Random Element    ${Genderlist}
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob} 

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid2}  ${locId}  ${kyc_list1}  firstName=${Custfname2}  lastName=${Custlname2}  phoneNo=${consumernumber2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite Variable  ${loanid2}    ${resp.json()['id']}
        Set Suite Variable  ${loanuid2}    ${resp.json()['uid']}
        
        ${resp}=  GetCustomer  phoneNo-eq=${consumernumber2}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable  ${custid2}  ${resp.json()[0]['id']}

    ELSE
        Set Suite Variable  ${custid2}      ${resp.json()[0]['id']}
        Set Suite Variable  ${Custfname2}  ${resp.json()[0]['firstname']}
        Set Suite Variable  ${Custlname2}  ${resp.json()[0]['lastname']}

        ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid2}  ${locId}  ${kyc_list1} 
        Log  ${resp.content}
        Should Be Equal As Strings     ${resp.status_code}    200
        Set Suite VAriable  ${loanid2}    ${resp.json()['id']}
        Set Suite VAriable  ${loanuid2}    ${resp.json()['uid']}

    END
    
    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid2}     ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no2}  ${resp.json()['referenceNo']}

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid2}    ${loanuid2}    ${consumernumber2}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid2}    ${loanuid2}    ${consumernumber2}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid2}     ${loanuid2}   ${consumernumber2}   ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid2}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid}  name=${categoryname}
    ${type}=           Create Dictionary    id=${typeid1}  name=${typename1}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid3}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid2}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid2}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid2}    ${loanuid2}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid2}    ${loanuid2}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid2}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid2}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid2}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid2}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid2}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  Encrypted Provider Login  ${BCOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid2}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid2} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#  .....Get Loan Applications Public APi call....

    ${resp}=  Get Loan Applications  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}


JD-TC-GetLoanApplications-4

    [Documentation]   create a loan applications by sales officer in another location
    ...   loc1 and branch3 and dealer4(credit approved)
    ...   and check get loan applications with user token 


# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=    Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locid1}  ${kyc_list1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid3}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid3}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Test Variable  ${kycid3}     ${resp.json()["loanApplicationKycList"][0]["id"]} 
    Set Suite Variable  ${ref_no3}  ${resp.json()['referenceNo']}

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
    
    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${resp}=   Requst For Aadhar Validation    ${custid}    ${loanuid3}    ${consumernumber}    ${aadhaar}    ${aadhaarAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details Aadhaar    ${kycid3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${resp}=    Requst For Pan Validation    ${custid}    ${loanuid3}    ${consumernumber}    ${pan}    ${panAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${panAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${jpgfile}  fileSize=${fileSize}  caption=${caption1}  fileType=${fileType1}  order=${order}
    Log  ${panAttachments}

    ${panAttachments}=  Create List    ${panAttachments}


    ${resp}=    Update loan Application Kyc Details    ${loanid3}     ${loanuid3}   ${consumernumber}   ${aadhaar}   ${pan}    ${aadhaarAttachments}    panAttachments=${panAttachments}    
    ...  permanentAddress1=velloor    permanentCity=malappuram    permanentPin=679581    permanentState=Kerala
    ...  currentAddress1=velloor    currentCity=malappuram    currentPin=679581    currentState=Kerala
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- KYC Details ------------------------------------------>

# <----------------------------- Loan Details ------------------------------------------>

    ${emiPaidAmountMonthly}    FakerLibrary.Random Number

    ${nomineeName}        FakerLibrary.name

    ${LoanApplicationKycList}=    Create Dictionary   id=${kycid3}  employmentStatus=${employmentStatus[0]}  monthlyIncome=${monthlyIncome}  nomineeType=${nomineeType[1]}  nomineeName=${nomineeName}    nomineeDob=20-10-1999   nomineePhone=5555555555
    ...  customerEducation=1    customerEmployement=1    salaryRouting=1    familyDependants=0    noOfYearsAtPresentAddress=1    currentResidenceOwnershipStatus=1    ownedMovableAssets=1  vehicleNo=KER369   goodsFinanced=1   earningMembers=1   existingCustomer=1
    Log  ${LoanApplicationKycList}

    ${category}=       Create Dictionary    id=${categoryid1}  name=${categoryname1}
    ${type}=           Create Dictionary    id=${typeid}  name=${typename}
    ${loanProducts}=    Create Dictionary    id=${Productid}  categoryId=${categoryid1}    typeId=${typeid}
    ${loanProducts}=    Create List    ${loanProducts}
    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  name=${Schemename1}

    ${partner}=  Create Dictionary  id=${partid4}
    Set Suite Variable    ${partner}

    ${resp}=    Verify loan Bank Details    ${loanid3}  ${loanProducts}  ${category}   ${type}    ${loanScheme}    ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${monthlyIncome}    ${emiPaidAmountMonthly}    ${LoanApplicationKycList}        uid=${loanuid3}   partner=${partner}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
# <----------------------------- Loan Details ------------------------------------------>

# <----------------------------- Bank Details ------------------------------------------>

    ${bankName}       FakerLibrary.name
    ${bankAddress1}   FakerLibrary.Street name
    ${bankAddress2}   FakerLibrary.Street name
    ${bankCity}       FakerLibrary.word
    ${bankState}      FakerLibrary.state

    ${bankStatementAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid2}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments}

    ${resp}=    Add loan Bank Details    4    ${loanuid3}    ${loanuid3}    ${bankName}    ${bankAccountNo}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin}    ${bankStatementAttachments}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${bankStatementAttachments2}=    Create Dictionary   action=${LoanAction[0]}  owner=${custid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${bankStatementAttachments2}

    ${resp}=    Update loan Bank Details    4    ${loanuid3}    ${loanuid3}    ${bankName}    ${bankAccountNo2}    ${bankIfsc}    ${bankAddress1}    ${bankAddress2}    ${bankCity}    ${bankState}   ${bankPin2}    ${bankStatementAttachments2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Verify loan Bank   ${loanuid3}    ${bankAccountNo2}    ${bankIfsc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get loan Bank Details    ${loanuid3}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable    ${kyid3}    ${resp.json()['id']}

# <----------------------------- Bank Details ------------------------------------------> 
    ${remark}=    FakerLibrary.sentence
    ${note}=      FakerLibrary.sentence

    ${resp}=    LoanApplication Remark        ${loanuid3}    ${remark}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Add General Notes    ${loanuid3}    ${note}
    Log    ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Approval        ${loanuid3}    
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


# ....... Loan approval by Branch credit head.......

    ${resp}=  Encrypted Provider Login  ${BCOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${loanScheme}=     Create Dictionary    id=${Schemeid1}  
    ${loanProduct}=    Create Dictionary    id=${Productid} 
    ${resp}=    Loan Application Manual Approval        ${loanuid3}    ${loanScheme}   ${invoiceAmount}    ${downpaymentAmount}    ${requestedAmount}    ${requestedAmount}    loanProduct=${loanProduct}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid3} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['spInternalStatus']}    ${LoanApplicationSpInternalStatus[4]}

    ${resp}=  ProviderLogout 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

#  .....Get Loan Applications Public APi call....

    ${resp}=  Get Loan Applications  ${user_token}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[3]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[3]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[3]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[3]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[3]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[3]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[3]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[3]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[3]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[3]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[3]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[3]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[3]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[3]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}


JD-TC-GetLoanApplications-5

    [Documentation]   check get loan applications with user token and id filter

    ${resp}=  Get Loan Applications  ${user_token}   id-eq=${loanid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanid1}
    Should Not Contain   ${resp.json()}    ${loanid2}
    Should Not Contain   ${resp.json()}    ${loanid3}
   
    ${resp}=  Get Loan Applications  ${user_token}   id-eq=${loanid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanid}
    Should Not Contain   ${resp.json()}    ${loanid2}
    Should Not Contain   ${resp.json()}    ${loanid3}
  
    ${resp}=  Get Loan Applications  ${user_token}   id-eq=${loanid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanid}
    Should Not Contain   ${resp.json()}    ${loanid1}
    Should Not Contain   ${resp.json()}    ${loanid3}

    ${resp}=  Get Loan Applications  ${user_token}   id-eq=${loanid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanid}
    Should Not Contain   ${resp.json()}    ${loanid1}
    Should Not Contain   ${resp.json()}    ${loanid2}

JD-TC-GetLoanApplications-6

    [Documentation]   check get loan applications with user token and uid filter

    ${resp}=  Get Loan Applications  ${user_token}   uid-eq=${loanUid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}
    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   uid-eq=${loanUid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid2}
    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   uid-eq=${loanUid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid3}

JD-TC-GetLoanApplications-7

    [Documentation]   check get loan applications with user token and referenceNo filter

    ${resp}=  Get Loan Applications  ${user_token}   referenceNo-eq=${ref_no}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${ref_no1}
    Should Not Contain   ${resp.json()}    ${ref_no2}
    Should Not Contain   ${resp.json()}    ${ref_no3}

    ${resp}=  Get Loan Applications  ${user_token}   referenceNo-eq=${ref_no1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${ref_no}
    Should Not Contain   ${resp.json()}    ${ref_no2}
    Should Not Contain   ${resp.json()}    ${ref_no3}

    ${resp}=  Get Loan Applications  ${user_token}   referenceNo-eq=${ref_no2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${ref_no}
    Should Not Contain   ${resp.json()}    ${ref_no1}
    Should Not Contain   ${resp.json()}    ${ref_no3}

JD-TC-GetLoanApplications-8

    [Documentation]   check get loan applications with user token and customer id filter

    ${resp}=  Get Loan Applications  ${user_token}   customer-eq=${custid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}
    
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}

JD-TC-GetLoanApplications-9

    [Documentation]   check get loan applications with user token and customer firstname filter

    ${resp}=  Get Loan Applications  ${user_token}   customerFirstName-eq=${Custfname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid2}
    Should Not Contain   ${resp.json()}    ${loanUid3}

JD-TC-GetLoanApplications-10

    [Documentation]   check get loan applications with user token and customer lastname filter

    ${resp}=  Get Loan Applications  ${user_token}   customerLastName-eq=${Custlname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid3}


JD-TC-GetLoanApplications-11

    [Documentation]   check get loan applications with user token and location filter

    ${resp}=  Get Loan Applications  ${user_token}   location-eq=${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   location-eq=${locid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}

JD-TC-GetLoanApplications-12

    [Documentation]   check get loan applications with user token and location name filter

    ${resp}=  Get Loan Applications  ${user_token}   locationName-eq=${locname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   locationName-eq=${locname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}

JD-TC-GetLoanApplications-13

    [Documentation]   check get loan applications with user token and category id filter

    ${resp}=  Get Loan Applications  ${user_token}   category-eq=${categoryid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   category-eq=${categoryid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}


JD-TC-GetLoanApplications-14

    [Documentation]   check get loan applications with user token and categoryName filter

    ${resp}=  Get Loan Applications  ${user_token}   categoryName-eq=${categoryname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid3}

    ${resp}=  Get Loan Applications  ${user_token}   categoryName-eq=${categoryname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}


JD-TC-GetLoanApplications-15

    [Documentation]   check get loan applications with user token and type id filter

    ${resp}=  Get Loan Applications  ${user_token}   type-eq=${typeid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid2}

    ${resp}=  Get Loan Applications  ${user_token}   type-eq=${typeid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid3}


JD-TC-GetLoanApplications-16

    [Documentation]   check get loan applications with user token and type name filter

    ${resp}=  Get Loan Applications  ${user_token}   typeName-eq=${typename}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid2}

    ${resp}=  Get Loan Applications  ${user_token}   typeName-eq=${typename1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid3}


JD-TC-GetLoanApplications-17

    [Documentation]   check get loan applications with user token and rejected filter

    ${resp}=  Encrypted Provider Login  ${BCOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Reject Loan Application   ${loanUid3}   ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Loan Applications  ${user_token}   isRejected-eq=${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid3}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid3}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid4}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername4} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid3}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName2}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}

    ${resp}=  Get Loan Applications  ${user_token}   isRejected-eq=${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid2}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid2}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname2}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber2}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['id']}            ${partid3}
    Should Be Equal As Strings   ${resp.json()[0]['partner']['partnerName']}   ${partnername3} 
    Should Be Equal As Strings   ${resp.json()[0]['branch']['id']}             ${branchid2}
    Should Be Equal As Strings   ${resp.json()[0]['branch']['branchName']}     ${branchName1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[1]['id']}                       ${loanid1}
    Should Be Equal As Strings   ${resp.json()[1]['uid']}                      ${loanUid1}
    Should Be Equal As Strings   ${resp.json()[1]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[1]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['id']}            ${partid2}
    Should Be Equal As Strings   ${resp.json()[1]['partner']['partnerName']}   ${partnername2} 
    Should Be Equal As Strings   ${resp.json()[1]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[1]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[1]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[1]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[1]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}

    Should Be Equal As Strings   ${resp.json()[2]['id']}                       ${loanid}
    Should Be Equal As Strings   ${resp.json()[2]['uid']}                      ${loanUid}
    Should Be Equal As Strings   ${resp.json()[2]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['id']}           ${custid}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['firstName']}    ${Custfname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['lastName']}     ${Custlname}
    Should Be Equal As Strings   ${resp.json()[2]['customer']['phoneNo']}      ${consumernumber}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['id']}            ${partid1}
    Should Be Equal As Strings   ${resp.json()[2]['partner']['partnerName']}   ${partnername1} 
    Should Be Equal As Strings   ${resp.json()[2]['branch']['id']}             ${branchid1}
    Should Be Equal As Strings   ${resp.json()[2]['branch']['branchName']}     ${branchName}
    Should Be Equal As Strings   ${resp.json()[2]['location']['id']}           ${locId}
    Should Be Equal As Strings   ${resp.json()[2]['location']['name']}         ${locname}
    Should Be Equal As Strings   ${resp.json()[2]['spInternalStatus']}         ${LoanApplicationSpInternalStatus[4]}


JD-TC-GetLoanApplications-18

    [Documentation]   check get loan applications with user token and spInternalStatus filter

# ..... Create Loan application By Sales officer.....

    ${resp}=  Encrypted Provider Login  ${SOUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${consumernumber1}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=    Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${consumernumber1}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid1}  ${locid1}  ${kyc_list1} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid4}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid4}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid4} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['spInternalStatus']}         ${LoanApplicationSpInternalStatus[0]}

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Loan Applications  ${user_token}   spInternalStatus-eq=${LoanApplicationSpInternalStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings   ${resp.json()[0]['id']}                       ${loanid4}
    Should Be Equal As Strings   ${resp.json()[0]['uid']}                      ${loanUid4}
    Should Be Equal As Strings   ${resp.json()[0]['accountId']}                ${account_id1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['id']}           ${custid1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['firstName']}    ${Custfname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['lastName']}     ${Custlname1}
    Should Be Equal As Strings   ${resp.json()[0]['customer']['phoneNo']}      ${consumernumber1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['id']}           ${locid1}
    Should Be Equal As Strings   ${resp.json()[0]['location']['name']}         ${locname1}
    Should Be Equal As Strings   ${resp.json()[0]['spInternalStatus']}            ${LoanApplicationSpInternalStatus[0]}

    Should Not Contain   ${resp.json()}    ${loanUid}
    Should Not Contain   ${resp.json()}    ${loanUid1}
    Should Not Contain   ${resp.json()}    ${loanUid2}
    Should Not Contain   ${resp.json()}    ${loanUid3}
