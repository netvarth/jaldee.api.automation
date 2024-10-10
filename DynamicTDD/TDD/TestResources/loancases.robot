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


*** Test Cases ***

JD-TC-CreateLoanApplication-1
    [Documentation]  Create Loan Application

    ${firstname}  ${lastname}  ${PhoneNumber}  ${NBFCPUSERNAME1}=  Provider Signup  PhoneNumber=${PhoneNumber}  LicenseId=${licid}  Domain=${Domain}  SubDomain=${SubDomain}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan    autoEmiDeductionRequire=${bool[1]}   partnerRequired=${bool[0]}  documentSignatureRequired=${bool[0]}   digitalSignatureRequired=${bool[1]}   emandateRequired=${bool[1]}   creditScoreRequired=${bool[1]}   equifaxScoreRequired=${bool[1]}   cibilScoreRequired=${bool[1]}   minCreditScoreRequired=${minCreditScoreRequired}   minEquifaxScoreRequired=${minEquifaxScoreRequired}   minCibilScoreRequired=${minCibilScoreRequired}   minAge=${minAge}   maxAge=${maxAge}   minAmount=${minAmount}   maxAmount=${maxAmount}   bankStatementVerificationRequired=${bool[1]}   eStamp=DIGIO 
    Log  ${resp.content}
    Should Be Equal As Strings            ${resp.status_code}   200

    ${resp}=  Create CDL Enquiry           ${category}  ${cust_id}  ${city}  ${aadhaar}  ${pan2}  ${state}  ${pin}  ${locId}  ${en_temp_id}  ${minAmount} 
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    Set Suite Variable                     ${en_id}                ${resp.json()['id']}
    Set Suite Variable                     ${en_uid}               ${resp.json()['uid']}

    # ....... Create Loan - Generate and verify phone for loan.......
    
    ${resp}=                               Generate Loan Application Otp for Phone Number    ${cust}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${gender}    Random Element            ${Genderlist}
    Set Suite Variable      ${gender}
    ${dob}=  FakerLibrary.Date Of Birth    minimum_age=23   maximum_age=55
    ${dob}=  Convert To String             ${dob} 
    Set Suite Variable      ${dob}
    ${kyc_list1}=  Create Dictionary       isCoApplicant=${bool[0]}
    Set Suite Variable      ${kyc_list1}

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id}  ${locId}   ${kyc_list1}  firstName=${fname}  lastName=${lname}  phoneNo=${cust}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200
    Set Suite VAriable                     ${loanid}              ${resp.json()['id']}
    Set Suite VAriable                     ${loanuid}             ${resp.json()['uid']}


JD-TC-CreateLoanApplication-UH1
    [Documentation]  Create Loan Application - where number is already used

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Generate Loan Application Otp for Phone Number    ${cust}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id}  ${locId}   ${kyc_list1}  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422

    Log  Create Loan Application - where number is already used

JD-TC-CreateLoanApplication-UH2
    [Documentation]  Create Loan Application - where phone number is empty

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${cust2}    Random Number  digits=5 
    ${cust2}=   Evaluate  f'{${cust2}:0>7d}'
    Log  ${cust2}
    Set Suite Variable                     ${cust2}  555${cust2}

    ${fname2}=                              FakerLibrary.name
    Set Suite Variable      ${fname2}
    ${lname2}=                              FakerLibrary.name
    Set Suite Variable      ${lname2}

    ${resp}=  GetCustomer                  phoneNo-eq=${cust2}  
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}     200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${cust2}    firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings         ${resp1.status_code}    200
        Set Suite Variable  ${cust_id2}      ${resp1.json()}
    ELSE
        Set Suite Variable  ${cust_id2}      ${resp.json()[0]['id']}
    END

    ${resp}=                               Generate Loan Application Otp for Phone Number    ${cust2}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${empty}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id2}  ${locId}   ${kyc_list1}  firstName=${fname2}  lastName=${lname2}  phoneNo=${cust2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}   ${ENTER_VALID_OTP}

    Log  Create Loan Application - where phone number is empty

JD-TC-CreateLoanApplication-UH3
    [Documentation]  Create Loan Application - where otp purpose is empty

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust2}  ${empty}  ${cust_id2}  ${locId}   ${kyc_list1}  firstName=${fname2}  lastName=${lname2}  phoneNo=${cust2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}   ${ENTER_VALID_OTP}

JD-TC-CreateLoanApplication-UH4
    [Documentation]  Create Loan Application - where customer id is empty

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${empty}  ${locId}   ${kyc_list1}  firstName=${fname2}  lastName=${lname2}  phoneNo=${cust2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}   ${ENTER_VALID_OTP}

    Log  Create Loan Application - where customer id is empty

JD-TC-CreateLoanApplication-UH5
    [Documentation]  Create Loan Application - where location id is empty

    ${resp}=  Encrypted Provider Login     ${SO_USERNAME}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings             ${resp.status_code}    200

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id2}  ${empty}   ${kyc_list1}  firstName=${fname2}  lastName=${lname2}  phoneNo=${cust2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}     
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    422
    Should Be Equal As Strings             ${resp.json()}   ${ENTER_VALID_OTP}

    Log  Create Loan Application - where location id is empty

JD-TC-CreateLoanApplication-UH6
                                  
    [Documentation]               Create Loan Application - without Login

    ${resp}=                               Verify Phone and Create Loan Application with customer details  ${cust2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${cust_id2}  ${locId}   ${kyc_list1}
    Log  ${resp.content}
    Should Be Equal As Strings             ${resp.status_code}    419
    Should BE Equal As Strings             ${resp.json()}         ${SESSION_EXPIRED}