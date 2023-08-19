*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}      0
@{emptylist}
${en_temp_name}   EnquiryName
${consumernumber}     55500000032
${locId}  207
@{custdeets}  firstname  lastname  phoneNo  countryCode  gender


*** Keywords ***

Verify Phone and Create Loan Application with customer details

    [Arguments]    ${loginId}   ${purpose}  ${id}  ${locid}     @{vargs}  &{custDetailskwargs}

    # ${customer}=  Create Dictionary      id=${id}  firstName=${firstName}  lastName=${lastName}  phoneNo=${phoneNo}  countryCode=${countryCode}
    ${location}=  Create Dictionary      id=${locid}
   
    # ${otp}=   verify accnt  ${loginId}  ${purpose}
    ${otp}=  Set Variable  55555

    ${len}=  Get Length  ${vargs}
    ${LoanApplicationKycList}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${LoanApplicationKycList}  ${vargs[${index}]}
    END

    ${customer}=  Create Dictionary      id=${id}

    Log Many  @{custDetailskwargs}
    FOR  ${key}  IN  @{custDetailskwargs}
        # Log  Key is "${key}" and value is "${custDetailskwargs}[${key}]".
        IF  '${key}' in @{custdeets}
            Set to Dictionary  ${customer}   ${key}=${custDetailskwargs}[${key}]
        END
    END

    ${loan}=  Create Dictionary   customer=${customer}  location=${location}   loanApplicationKycList=${LoanApplicationKycList}
    ${loan}=  json.dumps  ${loan}
    Log  ${loan}

    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/loanapplication/verify/${otp}/phone  data=${loan}  expected_status=any
    [Return]  ${resp}


*** Test Cases ***
TC-1

    ${gender}    Random Element    ${Genderlist}
    ${profile}=  FakerLibrary.profile   sex=female
    Set Test Variable  ${custid}   0
    ${Custfname}=  FakerLibrary.name
    ${Custlname}=  FakerLibrary.last_name
    # ${gender}    Random Element    ${Genderlist}
    ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    # Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstname=${Custfname}  lastname=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}

*** Comment ***
JD-TC-ChangeEnqStatus-1

    ${resp}=   ProviderLogin  ${PUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

