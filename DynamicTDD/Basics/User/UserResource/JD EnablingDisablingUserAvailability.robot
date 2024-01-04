***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Keywords ***
Enabling Disabling User Availability
    [Arguments]  ${userId}  ${status}
    Check And Create YNW Session
    ${resp}=    PUT On Session     ynw   /provider/user/${userId}/available/${status}   expected_status=any
    [Return]  ${resp}  

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facialmakeup 
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${country_code}   +91
@{UserStatus}   Online    Away    NotAvailable

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

${cc}   +91
${phone}     5555555555
${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       5555533

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${bankPin2}       5555589
${montlyIncome}  50000

${invoiceAmount}    10000
${downpaymentAmount}    2000
${requestedAmount}    8000

${invoiceAmount1}    5000
${downpaymentAmount1}    1000
${requestedAmount1}    4000

***Test Cases***
JD-TC-Enabling and Disabling User Availability-1
     [Documentation]  Create a user and Enabling and Disabling User Availability to Online status.
    #  ${resp}=  Encrypted Provider Login  ${HLMUSERNAME10}  ${PASSWORD}
    #  Log  ${resp.json()}
    #  Should Be Equal As Strings    ${resp.status_code}    200

     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+5859717
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+338466
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']} 

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}
     ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
     Should Be Equal As Strings  ${resp.status_code}  200
     @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
     Should Be Equal As Strings  ${resp[0].status_code}  200
     Should Be Equal As Strings  ${resp[1].status_code}  200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userAvailable']}  ${UserStatus[0]}


JD-TC-Enabling and Disabling User Availability-2
     [Documentation]  Create a user and Enabling and Disabling User Availability to  Away.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userAvailable']}  ${UserStatus[1]}


JD-TC-Enabling and Disabling User Availability-3
     [Documentation]  Create a user and Enabling and Disabling User Availability to NotAvailable.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userAvailable']}  ${UserStatus[2]}


JD-TC-Enabling and Disabling User Availability-4
     [Documentation]   Change Enabling and Disabling User Availability status two times.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['userAvailable']}  ${UserStatus[0]}


    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${USER_ALREADY_ONLINE}


JD-TC-Enabling and Disabling User Availability-5
     [Documentation]   create loan when user Availability is Online then change status to Away and do next step.

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id1}  ${decrypted_data['id']}
    # Set Test Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableBranchMaster']}  ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable  ${locId}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    clear Customer  ${MUSERNAME_E}

    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date

    ${resp}=  GetCustomer  phoneNo-eq=${phone} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phone}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${${phone}}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}
    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProducttype    ${account_id}
    ${resp}=  LoanProductCategory    ${account_id}
    ${resp}=  loanProducts    ${account_id}
    ${resp}=  loanScheme     ${account_id}
    # ${resp}=  loanProduct    ${account_id}


    ${resp}=  Generate Phone Partner Creation    ${phone}    ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}
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

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${uid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${user_id1}  ${resp.json()['id']}

    ${userids}=  Create List      ${user_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    
    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    


    # ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[0]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[2]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

# <----------------------------- Customer Details ------------------------------------------>

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${cc}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]} 

    

    ${resp}=    Generate Loan Application Otp for Email    ${email2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=   Verify Email Otp and Create Loan Application    ${email2}    5    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


*** comment ***

JD-TC-Enabling and Disabling User Availability-6
     [Documentation]   create loan when user Availability is Online then change status to Away and do next step.

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    clear Customer  ${MUSERNAME_E}

    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date

    ${resp}=  GetCustomer  phoneNo-eq=${phone} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phone}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${${phone}}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype       ${account_id}
    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProducttype    ${account_id}
    ${resp}=  LoanProductCategory    ${account_id}
    ${resp}=  loanProducts    ${account_id}
    ${resp}=  loanScheme     ${account_id}
    # ${resp}=  loanProduct    ${account_id}


    ${resp}=  Generate Phone Partner Creation    ${phone}    ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Verify Phone Partner Creation    ${phone}    14    ${firstName}   ${lastName}
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

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${uid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enabling Disabling User Availability    ${u_id}    ${UserStatus[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Loan Application Category
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${categoryid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Type
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${typeid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Status
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${statusid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Product
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Productid}  ${resp.json()[0]['id']}

    ${resp}=    Get Loan Application Scheme
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Schemeid}  ${resp.json()[0]['id']}

# <----------------------------- Customer Details ------------------------------------------>

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${cc}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${cc}    ${locId}    ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${kycid}     ${resp.json()["loanApplicationKycList"][0]["id"]} 