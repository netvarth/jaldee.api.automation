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
@{CDL}    Enable    Disable
${phone}     5555512345
${phone1}     5555512346

*** Test Cases ***

JD-TC-ReplaceUserScope-1

    [Documentation]  create a user without role and append a role then replace that role to another.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableRbac']}==${bool[0]}
        ${resp1}=  Enable Disable CDL RBAC  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

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

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    # ${resp}=   Run Keyword If  '${lic_id}' != '${lic2}'  Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    # Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${lic_id}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

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

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME140}'
                clear_users  ${user_phone}
            END
        END
    END

    ${user_scope}=  Create Dictionary
    ${capabilities}=  Create List

    ${role1}=  Create Dictionary   id=${role_id1}  roleName=${role_name1}  defaultRole=${bool[1]}
    ...   scope=${user_scope}   capabilities=${capabilities}
    ${user_roles}=  Create List   ${role1}

    ${u_id1}=  Create Sample User 
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME1}  ${resp.json()['mobileNo']}

    ${u_id2}=  Create Sample User 
    Set Suite Variable  ${u_id2}

    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME2}  ${resp.json()['mobileNo']}

    ${user_ids}=  Create List   ${u_id1}  ${u_id2}

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

    ${role2}=  Create Dictionary   id=${role_id2}  roleName=${role_name2} 
    ${user_roles2}=  Create List   ${role2}

    ${user_ids2}=  Create List   ${u_id1}

    ${resp}=  Replace User Scope  ${rbac_feature[0]}  ${user_ids2}  ${user_roles2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name2}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability2}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id2}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name2}
   
    ${resp}=  Get User By Id  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name1}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability1}
    
    Should Be Equal As Strings  ${resp.json()['defaultRoleId']}    ${role_id1}
    Should Be Equal As Strings  ${resp.json()['defaultRoleName']}  ${role_name1}

JD-TC-ReplaceUserScope-2

    [Documentation]  create a user as sales officer and create a loan then replace the role to bussiness operation head then try to create loan.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME140}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  partnercategorytype   ${account_id1}
    ${resp}=  partnertype           ${account_id1}
    ${resp}=  categorytype          ${account_id1}
    ${resp}=  tasktype              ${account_id1}
    ${resp}=  loanStatus            ${account_id1}
    ${resp}=  loanProducttype       ${account_id1}
    ${resp}=  LoanProductCategory   ${account_id1}
    ${resp}=  loanProducts          ${account_id1}
    ${resp}=  loanScheme            ${account_id1}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Run Keyword If  ${resp.json()['enableRbac']}==${bool[0]}   Enable Disable RBAC  ${toggle[0]}
    Run Keyword If  '${resp}' != '${None}'   Log  ${resp.content}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${branchCode}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode}
    ${branchName}=    FakerLibrary.name
    Set Suite Variable    ${branchName}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id3}=  Create Sample User 
    Set Suite Variable  ${u_id3}

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME3}  ${resp.json()['mobileNo']}

    ${u_id4}=  Create Sample User 
    Set Suite Variable  ${u_id4}

    ${resp}=  Get User By Id  ${u_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USERNAME4}  ${resp.json()['mobileNo']}

    ${loc_ids}=  Create List   ${locId}
    ${branch_ids}=  Create List   ${branchid1}
    ${users}=  Create List   ${u_id4} 
    ${user_scope}=  Create Dictionary  businessLocations=${loc_ids}  branches=${branch_ids}  
    ...  users=${users}
    ${role1}=  Create Dictionary   id=${role_id7}  roleName=${role_name7}  
    ...   scope=${user_scope} 
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id3}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${role1}=  Create Dictionary   id=${role_id4}  roleName=${role_name4}  
    ${user_roles}=  Create List   ${role1}

    ${user_ids}=  Create List   ${u_id4}  

    ${resp}=  Append User Scope  ${rbac_feature[0]}  ${user_ids}  ${user_roles} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${USERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME3}  ${PASSWORD}
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

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${Schemeid1}  ${resp.json()[1]['id']}
    Set Suite Variable  ${Schemeid2}  ${resp.json()[2]['id']}
    Set Suite Variable  ${Schemename}  ${resp.json()[0]['schemeName']} 

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

    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id1}  ${resp.json()['id']}
    Set Suite Variable  ${uuid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${uuid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${USERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${USERNAME4}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${uuid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${USERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME14}  firstName=${firstname}   lastName=${lastname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}
    Set Suite Variable    ${email}  ${lastname}${C_Email}.${test_mail}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]}    

    ${resp}=    Generate Loan Application Otp for Email    ${email}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email}    5    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${USERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${role2}=  Create Dictionary   id=${role_id4}  roleName=${role_name4} 
    ${user_roles2}=  Create List   ${role2}

    ${user_ids2}=  Create List   ${u_id3}

    ${resp}=  Replace User Scope  ${rbac_feature[0]}  ${user_ids2}  ${user_roles2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['id']}           ${role_id4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['roleName']}         ${role_name4}
    Should Be Equal As Strings  ${resp.json()['userRoles'][0]['defaultRole']}      ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['userRoles'][0]['capabilities']}     ${capability3}

    ${resp}=  Generate Phone Partner Creation    ${phone1}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone1}    14    ${firstName}   ${lastName}   branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${id1}  ${resp.json()['id']}
    Set Suite Variable  ${uuid1}  ${resp.json()['uid']} 
    





