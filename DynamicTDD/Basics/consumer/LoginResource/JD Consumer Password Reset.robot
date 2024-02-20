*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PasswordReset
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${NewPASSWORD}       Netvarth124


*** Test Cases ***

JD-TC-ResetPassword-1
    [Documentation]    Reset consumer login password 
    ${resp}=  Send Reset Email   ${CUSERNAME3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${CUSERNAME3}  ${NewPASSWORD}  3
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ResetPassword-2
    [Documentation]    verify user is not able to login using old password
    ${resp}=  Send Reset Email   ${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${CUSERNAME3}  ${PASSWORD}  3
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  401
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ResetPassword-3
    [Documentation]    Reset consumer login password with email and new valid password
    ${resp}=  Send Reset Email   ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${CUSERNAME5}  ${NewPASSWORD}  3
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Change Password  ${NewPASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-ResetPassword-UH1
    [Documentation]   Reuse the generated sharedkey
    @{resp}=  Reset Password  ${CUSERNAME3}  ${NewPASSWORD}  3
    Should Be Equal As Strings  ${resp[0].status_code}  404
    Should Be Equal As Strings  ${resp[1].status_code}  404

JD-TC-ResetPassword-UH2
    [Documentation]    Send reset mail to a non-member email id
    ${resp}=  Send Reset Email   ${Invalid_email}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${NOT_REGISTERED_USER}" 

JD-TC-ResetPassword-UH3
    [Documentation]    Reset provider login  password with valid userid and empty password
    ${resp}=  Send Reset Email  ${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${CUSERNAME3}  ${EMPTY}  3
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  422
    Should Be Equal As Strings  ${resp[1].json()}    ${PASSWORD_EMPTY}
    
JD-TC-ResetPassword-UH4
    [Documentation]    Reset provider login  password with an otp for different purpose
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH1}=  Evaluate  ${CUSERNAME}+100100601
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
    Set Suite Variable   ${CUSERPH1}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${CUSERMAIL1}=   Set Variable  ${C_Email}ph601.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERMAIL1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERMAIL1}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERMAIL1}  ${PASSWORD}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Reset Email  ${CUSERPH1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${CUSERPH1}  ${NewPASSWORD}  1
    Should Be Equal As Strings  ${resp[0].status_code}  422
    Should Be Equal As Strings  ${resp[1].status_code}  422
    Should Be Equal As Strings  ${resp[0].json()}    ${OTP_EXPIRED}
    Should Be Equal As Strings  ${resp[1].json()}    ${OTP_EXPIRED}

JD-TC-ResetPassword-UH5
    [Documentation]   Reset password of Provider using consumer urls
    ${resp}=  Send Reset Email   ${PUSERNAME0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Log   ${resp.content}
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"  

    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"
    # ${resp}=  Reset Password  ${PUSERNAME0}  ${NewPASSWORD}  3
    # Should Be Equal As Strings  ${resp[0].status_code}  200
    # Should Be Equal As Strings  ${resp[1].status_code}  200
    # ${resp}=  Consumer Login  ${PUSERNAME0}  ${NewPASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${NewPASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ResetPassword-4
    [Documentation]    Reset consumer login password with different country code
    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERPH3}=  Set Variable  ${PO_Number.national_number}
    Set Suite Variable   ${CUSERPH3}
    # Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}ph605.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH3_EMAIL}  countryCode=+${country_code}
    Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3_EMAIL}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}

    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH3}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  Reset Password  ${CUSERPH3}  ${NewPASSWORD}  3  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH3}  ${NewPASSWORD}  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ResetPassword-UH6
    [Documentation]    Reset consumer login password for same number with different country codes
    
    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${CUSERPH4}=  Evaluate  ${PUSERNAME}+${ran int}

    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code1}=  Set Variable  ${PO_Number.country_code}
   
    ${other_country_codes}=   random_country_codes  ${CUSERPH4}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}

    Comment   with default country code +91
   
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL}   countryCode=+${country_code1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
   
    Comment   Reset Password

    ${resp}=  Send Reset Email   ${CUSERPH4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  Reset Password  ${CUSERPH4}  ${NewPASSWORD}  3  
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH4}  countryCode=+${country_code1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NOT_REGISTERED_USER}


JD-TC-ResetPassword-6
    [Documentation]    Reset consumer login password with different country code when email address is given at signup
    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH5}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERPH5}=  Set Variable  ${PO_Number.national_number}
    Set Suite Variable   ${CUSERPH5}
    # Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH5}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+1000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${email}  Set Variable  ${lastname}${CUSERPH5}${C_Email}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${email}  countryCode=+${country_code}
    Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${email}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1   countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer By Id  ${CUSERPH5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH5}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  Reset Password  ${CUSERPH5}  ${NewPASSWORD}  3  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${NewPASSWORD}  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ResetPassword-7
    [Documentation]    Reset consumer login password with different country code when email address is updated
    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERPH5}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERPH5}=  Set Variable  ${PO_Number.national_number}
    Set Suite Variable   ${CUSERPH5}
    # Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH5}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH5}+1000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${email}  Set Variable  ${lastname}${CUSERPH5}${C_Email}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH5}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${email}  countryCode=+${country_code}
    Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${email}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1   countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH5}  ${PASSWORD}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Consumer Profile With Emailid    ${firstname}  ${lastname}  ${address}   ${dob}  ${gender}  ${email}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERPH5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH5}  countryCode=+${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  Reset Password  ${CUSERPH5}  ${NewPASSWORD}  3  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH5}  ${NewPASSWORD}  countryCode=+${country_code}
    Should Be Equal As Strings  ${resp.status_code}  200

    
***comment***

JD-TC-ResetPassword-4
    [Documentation]   Reset password of Provider using email
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${PUSEREMAIL6}=  Set Variable  ${P_Email}206.${test_mail}
    Set Suite Variable  ${PUSEREMAIL6}
    ${resp}=  Send Verify Login   ${PUSEREMAIL6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login   ${PUSEREMAIL6}  ${OtpPurpose['ProviderVerifyEmail']}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSEREMAIL6}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Reset Email   ${PUSEREMAIL6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${PUSEREMAIL6}  ${NewPASSWORD}  ${OtpPurpose['ConsumerResetPassword']}
    Log  ${resp}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${PUSEREMAIL6}  ${NewPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSEREMAIL6}  ${NewPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ResetPassword-7
    [Documentation]    verify provider is not able to login using old password
    ${resp}=  Send Reset Email   ${PUSEREMAIL6}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${PUSEREMAIL6}  ${PASSWORD}  ${OtpPurpose['ConsumerResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${PUSEREMAIL6}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  401
    ${resp}=  Consumer Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ResetPassword-4
    [Documentation]    verify provider is not able to login using old password
    ${resp}=  Send Reset Email   ${PUSERNAME0}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  Reset Password  ${PUSERNAME0}  ${PASSWORD}  3
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Consumer Login  ${PUSERNAME0}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  401
    ${resp}=  Consumer Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    
*** Comments ***


JD-TC-ResetPassword-5
    [Documentation]    Reset consumer login password for same number with different country codes
    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code1}    Generate random string    2    0123456789
    # ${country_code1}    Convert To Integer  ${country_code1}
    # ${country_code2}    Generate random string    3    0123456789
    # ${country_code2}    Convert To Integer  ${country_code2}

    FOR  ${p}  IN RANGE  5
        ${ran int}=    Generate Random String    length=4    chars=[NUMBERS]
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To Integer    ${ran int}
        ${ran int}=    Convert To String  ${ran int}
        ${Status}=   Run Keyword And Return Status   Should Match Regexp	${ran int}	\\d{4}
        Exit For Loop IF  ${Status}  
    END
    ${ran int}=    Convert To Integer    ${ran int}
    ${CUSERPH4}=  Evaluate  ${PUSERNAME}+${ran int}

    ${PO_Number}=  random_phone_num_generator
    Log  ${PO_Number}
    ${country_code1}=  Set Variable  ${PO_Number.country_code}
    # ${CUSERPH4}=  Set Variable  ${PO_Number.national_number}

    ${other_country_codes}=   random_country_codes  ${CUSERPH4}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}

    Comment   with default country code +91
    # ${CUSERPH4}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH4}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH4}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4}  ${PASSWORD}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL}   countryCode=+${country_code1}
    Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL}  1
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    Comment   with country code   ${country_code2}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH4_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code2}.${test_mail}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH4}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${CUSERPH4_EMAIL}   countryCode=+${country_code2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_PHONE}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${CUSERPH4_EMAIL}  1
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${CUSERPH4_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code2}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    Comment   Reset Password

    ${resp}=  Send Reset Email   ${CUSERPH4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  Reset Password  ${CUSERPH4}  ${NewPASSWORD}  3  
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH4}  countryCode=+${country_code1}
    Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NOT_REGISTERED_USER}

    @{resp}=  Reset Password  ${CUSERPH4}  ${NewPASSWORD}  3  countryCode=+${country_code1}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}  countryCode=+${country_code1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Reset Email   ${CUSERPH4}  countryCode=+${country_code2}
    Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NOT_REGISTERED_USER}
   
    @{resp}=  Reset Password  ${CUSERPH4}  ${NewPASSWORD}  3  countryCode=+${country_code2}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}  countryCode=+${country_code2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Comment   Login

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}  countryCode=+${country_code1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH4}  ${NewPASSWORD}  countryCode=+${country_code2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
