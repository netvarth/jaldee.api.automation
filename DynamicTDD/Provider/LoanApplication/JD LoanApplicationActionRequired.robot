*** Settings ***


Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***


@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458


${phone}     5555512345
${phone2}     5555512331

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***



JD-TC-Loan_Application_Action_Required-1
                                  
    [Documentation]               Loan Application Action Required

    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    clear Customer  ${PUSERNAME69}

    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    ${lname}=    FakerLibrary.lastName
    Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}

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
    Set Suite Variable   ${phoneNo}    ${resp.json()[0]['phoneNo']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableBranchMaster']}==${bool[0]}
        ${resp1}=  Enable Disable Branch    ${status[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${place}  ${resp.json()[0]['place']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
   
    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${branchid2}  ${resp.json()['id']}

    ${resp}=    Change Branch Status    ${branchid2}    ${bool[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # .....Assigning branches to users

    ${userids}=  Create List  ${provider_id}
    ${branch1}=  Create Dictionary   id=${branchid2}    isDefault=${bool[1]}

    ${resp}=  Assigning Branches to Users   ${userids}   ${branch1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  categorytype   ${account_id}
    ${resp}=  tasktype       ${account_id}
    ${resp}=  loanStatus     ${account_id}
    ${resp}=  loanProduct    ${account_id}
    ${resp}=  loanScheme     ${account_id}

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

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid}    ${firstName}    ${lastName}    ${phoneNo}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid}    ${resp.json()['uid']}

    ${resp}=    Get Loan Application By uid  ${loanuid} 
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite Variable  ${sp_internal}    ${resp.json()['spInternalStatus']}


    ${note}     FakerLibrary.sentence
    Set Suite Variable    ${note}

    ${resp}=    Loan Application Action Completed    ${note}    ${loanuid}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${resp}=    Loan Application Action Required    ${note}    ${loanuid}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

JD-TC-Loan_Application_Action_Required-UH1
                                  
    [Documentation]               Loan Application Action Required Where note is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Loan Application Action Required    ${empty}    ${loanuid}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_NOTE} 

JD-TC-Loan_Application_Action_Required-UH2
                                  
    [Documentation]               Loan Application Action Required Where loan uid is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Loan Application Action Required    ${note}    ${empty}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID} 

JD-TC-Loan_Application_Action_Required-UH3
                                  
    [Documentation]               Loan Application Action Required Where loan statusid is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Loan Application Action Required    ${note}    ${loanuid}    ${SPACE}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422

JD-TC-Loan_Application_Action_Required-UH4
                                  
    [Documentation]               Loan Application Action Required With invalid launid

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${loan_uids}=  Generate Random String  3  [NUMBERS]

    ${resp}=    Loan Application Action Required    ${note}    ${loan_uids}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${INVALID_LOAN_APPLICATION_ID} 

JD-TC-Loan_Application_Action_Required-UH5
                                  
    [Documentation]               Loan Application Action Required With  invalid status id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${status2}=  Generate Random String  3  [NUMBERS]

    ${resp}=    Loan Application Action Required    ${note}    ${loanuid}    ${status2}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${ALREADY_UPDATED} 

JD-TC-Loan_Application_Action_Required-UH6
                                  
    [Documentation]               Loan Application Action Required Without login 

    ${resp}=    Loan Application Action Required    ${note}    ${loanuid}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}

JD-TC-Loan_Application_Action_Required-UH7
                                  
    [Documentation]               Loan Application Action Required which is created for another provider

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Loan Application Action Required    ${note}    ${loanuid}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    422
    Should Be Equal As Strings   ${resp.json()}  ${NO_PERMISSION}

JD-TC-Loan_Application_Action_Required-UH8
                                  
    [Documentation]               Loan Application Action Required where loan application action is not completed
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${place}  ${resp.json()[0]['place']}
    END

    clear Customer  ${PUSERNAME69}

    # Set Suite Variable  ${email2}  ${lname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date Of Birth   minimum_age=23   maximum_age=55
    ${dob}=  Convert To String  ${dob}
    ${fname}=    FakerLibrary.firstName
    ${lname}=    FakerLibrary.lastName

    ${resp}=  GetCustomer  phoneNo-eq=${phone2} 
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${phone2}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid1}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid1}  ${resp.json()[0]['id']}
    END
    ${resp}=  GetCustomer  phoneNo-eq=${phone2}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable   ${custid2}    ${resp.json()[0]['id']}

    ${resp}=    Generate Loan Application Otp for Phone Number    ${phone2}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200

    ${kyc_list1}=           Create Dictionary  isCoApplicant=${bool[0]}
    
    # ${resp}=    Verify Phone Otp and Create Loan Application   ${phone2}   ${OtpPurpose['ConsumerVerifyPhone']}   ${custid2}    ${fname}    ${lname}    ${phone2}    ${countryCodes[0]}    ${locId}    ${kyc_list1}
    ${resp}=  Verify Phone and Create Loan Application with customer details  ${phone2}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid2}  ${locId}  ${kyc_list1}  firstName=${fname}  lastName=${lname}  phoneNo=${phone2}  countryCode=${countryCodes[0]}  gender=${gender}  dob=${dob}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200
    Set Suite VAriable  ${loanid2}    ${resp.json()['id']}
    Set Suite VAriable  ${loanuid2}    ${resp.json()['uid']}

    ${note2}     FakerLibrary.sentence
    Set Suite Variable    ${note2}

    ${resp}=    Loan Application Action Required    ${note2}    ${loanuid2}    ${sp_internal}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200