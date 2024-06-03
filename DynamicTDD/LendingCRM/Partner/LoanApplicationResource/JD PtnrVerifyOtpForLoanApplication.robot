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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458


${aadhaar}   555555555555
${pan}       5555523145
${bankAccountNo}    5555534564
${bankIfsc}         5555566
${bankPin}       555553
${invpin}        1234

${bankAccountNo2}    5555534587
${bankIfsc2}         55555688
${monthlyIncome}  50000
${bankPin2}       555558

${invoiceAmount}    100000
${downpaymentAmount}    20000
${requestedAmount}    80000

*** Test Cases ***

JD-TC-Verify OTP For Loan Application-1
                                  
    [Documentation]              Verify OTP For Loan Application

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

*** Comments ***

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
    Set Test Variable   ${lic_id}   ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
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
    ${firstName}=    FakerLibrary.firstName
    ${lastName}=    FakerLibrary.lastName


    ${so_id1}=  Create Sample User 
    Set Suite Variable  ${so_id1}
    
    ${resp}=  Get User By Id  ${so_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${SOUSERNAME1}  ${resp.json()['mobileNo']}

    ${bch_id1}=  Create Sample User 
    Set Suite Variable  ${bch_id1}

    ${resp}=  Get User By Id  ${bch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BCHUSERNAME1}  ${resp.json()['mobileNo']}

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
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchid1}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid1}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${userids}=  Create List  ${so_id1}   ${bch_id1}

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

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${P_phone}  555${PH_Number}

    ${resp}=  Generate Phone Partner Creation    ${P_phone}    ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${branch}=      Create Dictionary   id=${branchid1}

    ${resp}=  Verify Phone Partner Creation    ${P_phone}    ${OtpPurpose['ProviderVerifyPhone']}    ${firstName}   ${lastName}    branch=${branch}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${Pid1}  ${resp.json()['id']}
    Set Suite Variable  ${Puid1}  ${resp.json()['uid']} 

    ${resp}=    Get Partner-With Filter
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=   Partner Approval Request    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${note}=    FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=   Partner Approved    ${Puid1}    ${note}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

# ...... Update sales officer and credit officer for dealer1 & activate dealer1 by branch operation head....

    ${Salesofficer}=    Create Dictionary    id=${so_id1}  isDefault=${bool[1]}

    ${resp}=    Update Sales Officer    ${Puid1}    ${Salesofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${Creditofficer}=    Create Dictionary    id=${bch_id1}    isDefault=${bool[1]}

    ${resp}=    Update Credit Officer    ${Puid1}      ${Creditofficer}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Activate Partner    ${Puid1}     ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

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

    ${resp}=    Get Partner by UID    ${Puid1}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Partner Reset Password    ${account_id}  ${P_phone}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    511 
    Should Be Equal As Strings   ${resp.json()}   otp authentication needed
    # Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Verify Otp For Login Partner  ${P_phone}  ${OtpPurpose['Authentication']}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Complete Partner Reset Password    ${account_id}  ${P_phone}  ${PASSWORD}  ${token}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
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
        Set Suite Variable  ${custid}   0
        ${gender}    Random Element    ${Genderlist}
        ${Custfname}=  FakerLibrary.name
        ${Custlname}=  FakerLibrary.last_name
        ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
        ${dob}=  Convert To String  ${dob}
        # ${dob}=  FakerLibrary.Date
        ${custDetails}=  Create Dictionary  firstName=${Custfname}  lastName=${Custlname}  phoneNo=${consnum}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
        
    ELSE
        Set Suite Variable  ${custid}  ${resp.json()[0]['id']}
        ${custDetails}=  Create Dictionary
    END   
    
    Set Suite Variable    ${custDetails}

    ${resp}=    Partner Generate Loan Application Otp For Phone Number    ${consnum}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    Set Suite Variable    ${kyc_list1}
    ${CustomerPhoto}=    Create List
    
    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}    ${CustomerPhoto}   ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${loanid}    ${resp.json()['id']}
    Set Suite Variable  ${loanuid}    ${resp.json()['uid']}


JD-TC-Verify OTP For Loan Application-2
                                  
    [Documentation]              Verify OTP For Loan Application withy invalid mobile number

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invconsnum}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${invconsnum}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-3
                                  
    [Documentation]              Verify OTP For Loan Application withy empty mobile number

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${empty}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-4
                                  
    [Documentation]              Verify OTP For Loan Application withy invalid otp purpose

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invconsnum}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-5
                                  
    [Documentation]              Verify OTP For Loan Application withy empty otp purpose

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${empty}  ${custid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-6
                                  
    [Documentation]              Verify OTP For Loan Application withy invalid customer id

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invcustid}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${invcustid}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-7
                                  
    [Documentation]              Verify OTP For Loan Application withy empty customer id

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${empty}  ${locId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-8
                                  
    [Documentation]              Verify OTP For Loan Application invalid location id

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invlocId}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${custid}  ${invlocId}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-9
                                  
    [Documentation]              Verify OTP For Loan Application empty location id

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invlocId}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${custid}  ${empty}  ${kyc_list1}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}   ${ENTER_VALID_OTP}


JD-TC-Verify OTP For Loan Application-10
                                  
    [Documentation]              Verify OTP For Loan Application empty kyc list

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invlocId}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${custid}  ${locId}  ${empty}  &{custDetails}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500


JD-TC-Verify OTP For Loan Application-11
                                  
    [Documentation]              Verify OTP For Loan Application empty customer details

    ${resp}=    Login Partner with Password    ${account_id}  ${P_phone}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${invlocId}    Random Number 	digits=5

    ${resp}=  Partner Verify Number and Create Loan Application with customer details  ${consnum}  ${OtpPurpose['ProviderSignUp']}  ${custid}  ${locId}  ${kyc_list1}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    500