*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        LOAN
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

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${phonenum1}     5555573875
${phonenum2}     5555912364
${phonenum3}     5557831283
${phonenum4}     5553368962
${phonenum5}     5557896781
${phone}         5555512398
${order}    0
${fileSize}  0.00458

${cc}   +91
${aCC}  +96
${acc12}  +46

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***

JD-TC-GenerateotpForPhoneNum-1
                                  
    [Documentation]               Generate otp for phone Num

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${provider_id1}  ${resp.json()['id']}
    Set Test Variable   ${lic_id}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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


    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    ${lname}=    FakerLibrary.lastName
    Set Suite Variable  ${email2}  ${lname}${C_Email}.ynwtest@netvarth.com

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
    ${resp}=  GetCustomer  phoneNo-eq=${phone}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}

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

    ${userids}=  Create List      ${provider_id1}

    ${branch1}=  Create Dictionary   id=${branchid1}    isDefault=${bool[1]}
    # ${branch2}=  Create Dictionary   id=${branchid2}    isDefault=${bool[0]}

    ${resp}=  Assigning Branches to Users     ${userids}     ${branch1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${resp}=  partnercategorytype   ${account_id}
    ${resp}=  partnertype           ${account_id}
    ${resp}=  categorytype          ${account_id}
    ${resp}=  tasktype              ${account_id}
    ${resp}=  loanStatus            ${account_id}
    ${resp}=  loanProducttype       ${account_id}
    ${resp}=  LoanProductCategory   ${account_id}
    ${resp}=  loanProducts          ${account_id}
    ${resp}=  loanScheme            ${account_id}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phone}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phone}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}


JD-TC-GenerateotpForPhoneNum-2
                                  
    [Documentation]               different countryCode


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    ${lname}=    FakerLibrary.lastName
    Set Suite Variable  ${email2}  ${lname}${C_Email}.ynwtest@netvarth.com

    ${resp}=  GetCustomer  phoneNo-eq=${phonenum5} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phonenum5}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid14}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid14}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${${phonenum5}}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid}    ${resp.json()[0]['id']}
    Set Suite Variable   ${firstName}    ${resp.json()[0]['firstName']}
    Set Suite Variable   ${lastName}    ${resp.json()[0]['lastName']}

    

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum5}   ${countryCodes[2]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phonenum5}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phonenum5}    ${countryCodes[2]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phonenum5}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phonenum5}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200




JD-TC-GenerateotpForPhoneNum-3
                                  
    [Documentation]              generate 2 otp for same phone num different country code


    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum3}   ${countryCodes[2]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum3}   ${countryCodes[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


    # ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phonenum3}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo3}    ${aCC}    ${locId}    ${kyc_list1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phonenum3}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo3}    ${acc12}    ${locId}    ${kyc_list1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-GenerateotpForPhoneNum-4
                                  
    [Documentation]               generate otp same country code different phone num

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum4}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum5}   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200


    # ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phonenum4}   13   ${custid}    ${firstName}    ${lastName}    ${phoneNo4}    ${aCC}    ${locId}    ${kyc_list1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    422
    # Should be Equal As Strings    ${resp.json()}    ${ENTER_VALID_OTP}


JD-TC-GenerateotpForPhoneNum-5

                                  
    [Documentation]               invalid country code

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum4}   gnj
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    
    # ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${CUSERNAME30}   13   ${custid}    ${firstName}    ${lastName}    ${CUSERNAME30}    ${cc}    ${locId}    ${kyc_list1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}   200 

JD-TC-GenerateotpForPhoneNum-6
                                  
    [Documentation]               invalid phone num

    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME7}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Generate Loan Application Otp for Phone Number    5ftchv   ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    
    
    # ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phoneNo}   13   ${custid}    ${firstName}    ${lastName}    5ftchv    ${cc}    ${locId}    ${kyc_list1}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-GenerateotpForPhoneNum-7
                                  
    [Documentation]               consumer Login  

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}


    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum5}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    401
    


JD-TC-GenerateotpForPhoneNum-8
                                  
    [Documentation]               without login

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phonenum5}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    