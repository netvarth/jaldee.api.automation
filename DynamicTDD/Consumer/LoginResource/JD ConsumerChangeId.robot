*** Settings ***
Suite Teardown    Delete All Sessions
Force Tags        ConsumerLogin
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${self}     0

*** Test Cases ***


JD-TC-Update consumer number-1

    [Documentation]     Update a consumer number

    ${CUSERNAME_0}=  Evaluate  ${PUSERNAME}+406337222
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${CUSERNAME_0}${C_Email}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${newNo}=  Evaluate  ${PUSERNAME33}+77898
    Set Suite Variable    ${newNo}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    # ${address1}=  FakerLibrary.Address
    ${resp}=  Update Consumer Profile With Emailid    ${firstname1}  ${lastname1}  ${EMPTY}   ${dob1}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${newNo}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login Consumer   ${newNo}  5
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${newNo}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${newNo}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname1}  lastName=${lastname1}  dob=${dob1}   

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

JD-TC-Update consumer number-UH1

    [Documentation]     Update a consumer number with same number

    ${CUSERNAME_0}=  Evaluate  ${PUSERNAME}+406337223
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76067
    Set Test Variable  ${email}  ${firstname}${CUSERNAME_0}${C_Email}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    # ${address1}=  FakerLibrary.Address
    ${resp}=  Update Consumer Profile With Emailid    ${firstname1}  ${lastname1}  ${EMPTY}   ${dob1}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${SAME_MOBILE_NO_USED}"

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname1}  lastName=${lastname1}  dob=${dob1}   



JD-TC-Update consumer number-UH2

    [Documentation]     Update a consumer number with already registerd number

    ${CUSERNAME_0}=  Evaluate  ${PUSERNAME}+406337224
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76066
    Set Test Variable  ${email}  ${firstname}${CUSERNAME_0}${C_Email}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${resp}=  Update Consumer Profile With Emailid    ${firstname1}  ${lastname1}  ${EMPTY}   ${dob1}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME10}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${MOBILE_NO_USED}"

JD-TC-Update consumer number-2

    [Documentation]     Update a consumer number with different country code

    # ${PO_Number}    Generate random string    5    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    # ${CUSERNAME_0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # ${PO_Number}=  random_phone_num_generator
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${country_code}=  Convert To String  ${country_code}
    ${CUSERNAME_0}=  Set Variable  ${PO_Number.national_number}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${new_Number}    Generate random string    10    0123456789
    # ${new_Number}    Convert To Integer  ${new_Number}
    ${other_numbers}=   country_code_numbers  ${country_code}
    Log  ${other_numbers}
    Log List  ${other_numbers}
    Append To List  ${other_numbers}  ${CUSERNAME_0}
    ${unique_numbers}=    Remove Duplicates    ${other_numbers}
    Remove Values From List  ${unique_numbers}  ${CUSERNAME_0}
    ${new_Number}=  Evaluate  random.choice($unique_numbers)  random
    Remove Values From List  ${unique_numbers}  ${new_Number}
    # ${newNo}=  Evaluate  ${PUSERNAME33}+77898
    # Set Suite Variable    ${newNo}

    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    # ${address1}=  FakerLibrary.Address
    ${resp}=  Update Consumer Profile With Emailid    ${firstname1}  ${lastname1}  ${EMPTY}   ${dob1}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=  Send Verify Login Consumer   ${new_Number}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

    ${resp}=  Verify Login Consumer   ${new_Number}  5  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${new_Number}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer By Id  ${new_Number}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname1}  lastName=${lastname1}  dob=${dob1}   

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"


# *** comment ***
JD-TC-Update consumer number-3

    [Documentation]     Update a consumer's phone number with different country code and then update it back to old country code

    
    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code}=  Set Variable  ${PO_Number.country_code}
    ${CUSERNAME_0}=  Set Variable  ${PO_Number.national_number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Activation  ${CUSERNAME_0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Set Credential  ${CUSERNAME_0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Consumer Profile With Emailid    ${firstname}  ${lastname}  ${EMPTY}   ${dob}  ${EMPTY}  ${email}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  5  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}   

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  5
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"


JD-TC-Update consumer number-4

    [Documentation]     create 2 consumers with same number, different country codes and update one consumer's number to another country code

    # ${PO_Number}=  random_phone_num_generator
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code1}=  Set Variable  ${PO_Number.country_code}
    ${Consumer1}=  Set Variable  ${PO_Number.national_number}

    ${other_country_codes}=   random_country_codes  ${Consumer1}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}

    Comment   with default country code +91
    # ${Consumer1}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${Consumer1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${Consumer1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${Consumer1}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${Consumer1}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${Consumer1_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${Consumer1_EMAIL}   countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${Consumer1_EMAIL}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${Consumer1_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Verify Login Consumer   ${Consumer1}  countryCode=${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

    ${resp}=  Verify Login Consumer   ${Consumer1}  5  countryCode=${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"


JD-TC-Update consumer number-UH3

    [Documentation]     create 2 consumers with same number, different country codes and update one consumer's country code to the other consumer's country code

    # ${PO_Number}    Generate random string    4    0123456789
    # ${PO_Number}    Convert To Integer  ${PO_Number}
    # ${country_code1}    Generate random string    2    0123456789
    # ${country_code1}    Convert To Integer  ${country_code1}
    # ${country_code2}    Generate random string    3    0123456789
    # ${country_code2}    Convert To Integer  ${country_code2}

    # ${PO_Number}=  random_phone_num_generator
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code1}=  Set Variable  ${PO_Number.country_code}
    ${Consumer1}=  Set Variable  ${PO_Number.national_number}

    ${other_country_codes}=   random_country_codes  ${Consumer1}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}

    Comment   with default country code +91
    # ${Consumer1}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${Consumer1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${Consumer1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${Consumer1}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${Consumer1}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   with country code   ${country_code1}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${Consumer1_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${Consumer1_EMAIL}   countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${Consumer1_EMAIL}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${Consumer1_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Verify Login Consumer   ${Consumer1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${MOBILE_NO_USED}"

    # ${resp}=  Verify Login Consumer   ${Consumer1}  5
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=${country_code1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"

JD-TC-Update consumer number-UH4

    [Documentation]     create 2 consumers with different numbers and country codes and update one consumer's international number to the other consumer's number

    # ${PO_Number1}    Generate random string    5    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${PO_Number2}    Generate random string    6    0123456789
    # ${PO_Number2}    Convert To Integer  ${PO_Number2}
    # ${country_code1}    Generate random string    2    0123456789
    # ${country_code1}    Convert To Integer  ${country_code1}
    # ${country_code2}    Generate random string    3    0123456789
    # ${country_code2}    Convert To Integer  ${country_code2}

    # ${PO_Number}=  random_phone_num_generator
    ${PO_Number}=  Get Random Valid Phone Number
    Log  ${PO_Number}
    ${country_code1}=  Set Variable  ${PO_Number.country_code}
    ${country_code1}=  Convert To String  ${country_code1}
    ${Consumer1}=  Set Variable  ${PO_Number.national_number}

    ${other_numbers}=   country_code_numbers  ${country_code1}
    Log  ${other_numbers}
    Log List  ${other_numbers}
    Append To List  ${other_numbers}  ${Consumer1}
    ${unique_numbers}=    Remove Duplicates    ${other_numbers}
    Remove Values From List  ${unique_numbers}  ${Consumer1}
    ${Consumer2}=  Evaluate  random.choice($unique_numbers)  random
    Remove Values From List  ${unique_numbers}  ${Consumer2}

    ${other_country_codes}=   random_country_codes  ${Consumer2}
    Log  ${other_country_codes}
    Log List  ${other_country_codes}
    Append To List  ${other_country_codes}  ${country_code1}
    ${unique_ccodes}=    Remove Duplicates    ${other_country_codes}
    Remove Values From List  ${unique_ccodes}  ${country_code1}
    ${country_code2}=  Evaluate  random.choice($unique_ccodes)  random
    Remove Values From List  ${unique_ccodes}  ${country_code2}

    Comment   with country code   ${country_code1}
    # ${Consumer1}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${Consumer1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${Consumer1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${Consumer1_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code1}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${Consumer1_EMAIL}  countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${Consumer1_EMAIL}  1  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${Consumer1_EMAIL}  ${PASSWORD}  1    countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=+${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    Comment   with country code   ${country_code2}
    
    # ${Consumer2}=  Evaluate  ${CUSERNAME}+${PO_Number2}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${Consumer2}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${Consumer2}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${Consumer2_EMAIL}=   Set Variable  ${C_Email}${lastname}${country_code2}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${Consumer2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${Consumer2_EMAIL}   countryCode=+${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${Consumer2_EMAIL}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${Consumer2_EMAIL}  ${PASSWORD}  1   countryCode=+${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${Consumer2}  ${PASSWORD}  countryCode=+${country_code2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Send Verify Login Consumer   ${Consumer1}  countryCode=${country_code1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${MOBILE_NO_USED}"

    # ${resp}=  Verify Login Consumer   ${Consumer1}  5  countryCode=${country_code1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${Consumer1}  ${PASSWORD}  countryCode=${country_code1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${Consumer2}  ${PASSWORD}  countryCode=${country_code2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"


JD-TC-Update consumer number-UH5
    [Documentation]     change consumer phone number without country code

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    # ${country_code}    Generate random string    2    0123456789
    # ${country_code}    Convert To Integer  ${country_code}
    ${CUSERNAME_0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${email}   +91
    Should Be Equal As Strings    ${resp.status_code}    200
   ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${new_Number}    Generate random string    10    0123456789
    ${new_Number}    Convert To Integer  ${new_Number}

    # ${firstname1}=  FakerLibrary.name
    # ${lastname1}=  FakerLibrary.last_name
    # ${dob1}=  FakerLibrary.Date
    # # ${gender1}=  Random Element    ${Genderlist}
    # # ${address1}=  FakerLibrary.Address
    # ${resp}=  Update Consumer Profile With Emailid    ${firstname1}  ${lastname1}  ${EMPTY}   ${dob1}  ${EMPTY}  ${email}  
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${newNo}  countryCode=${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

    # ${resp}=  Verify Login Consumer   ${newNo}  5  countryCode=${EMPTY}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${newNo}  ${PASSWORD}
    # Log  ${resp.content}
    # # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"

    # ${resp}=  Get Consumer By Id  ${newNo}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Consumer Profile  ${resp}  firstName=${firstname1}  lastName=${lastname1}  dob=${dob1}   

    # ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_USER}"


JD-TC-Update consumer number-UH6
    [Documentation]     change consumer phone number with invalid country code

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${CUSERNAME_0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${CUSERNAME_0}+${alt_Number}
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME_0}   ${alternativeNo}  ${dob}  ${gender}   ${email}   +91
    Should Be Equal As Strings    ${resp.status_code}    200
   ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME_0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    

    ${new_Number}    Generate random string    10    0123456789
    ${new_Number}    Convert To Integer  ${new_Number}

    ${country_code}    Generate random string    3   0123456789
    ${country_code}    Convert To Integer  ${country_code}

    ${resp}=  Send Verify Login Consumer   ${newNo}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_COUNTRY_CODE}"

JD-TC-Update consumer number-5
    [Documentation]     consumer takes checkin and then consumer updates login id.

    ${resp}=  Provider Login  ${PUSERNAME38}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME38}
    clear_service    ${PUSERNAME38}
    clear_customer   ${PUSERNAME38}
    clear_provider_msgs  ${PUSERNAME38}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME38}

    ${DAY1}=  get_date
    
    ${resp}=  Sample Queue   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}  queueState=${Qstate[0]}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # clear_consumer_msgs  ${CUSERPH3}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}   waitlistedBy=${waitlistedby[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}

    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${alternativeNo}=  Evaluate  ${CUSERPH3}+${alt_Number}

    ${resp}=  Send Verify Login Consumer   ${alternativeNo}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login Consumer   ${alternativeNo}  5  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${alternativeNo}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Update consumer number-6
    [Documentation]     Provider takes checkin for consumer and then consumer updates login id.

    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${CUSERPH3}=  Evaluate  ${CUSERNAME}+${PO_Number}
    # clear_consumer_msgs  ${CUSERPH3}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH3}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${CUSERPH3_EMAIL}=   Set Variable  ${C_Email}${lastname}${PO_Number}.ynwtest@netvarth.com
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH3}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH3}  ${PASSWORD}  1  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    
    ${resp}=  Provider Login  ${PUSERNAME38}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bsname}  ${resp.json()['businessName']}
    Set Test Variable  ${pid}  ${resp.json()['id']}
    Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_location   ${PUSERNAME38}
    clear_service    ${PUSERNAME38}
    clear_customer   ${PUSERNAME38}
    clear_provider_msgs  ${PUSERNAME38}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
	
    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    
    ${lid}=  Create Sample Location  
    clear_queue   ${PUSERNAME38}

    ${DAY1}=  get_date
    
    ${resp}=  Sample Queue   ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}  queueState=${Qstate[0]}

    ${resp}=  AddCustomer  ${CUSERPH3}  firstName=${firstname}   lastName=${lastname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${DAY1}=  get_date
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wl_json}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wl_json[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}   waitlistedBy=${waitlistedby[1]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}           
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${fname}  
    Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${q_id}

    ${alt_Number}    Generate random string    5    0123456789
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${alternativeNo}=  Evaluate  ${CUSERPH3}+${alt_Number}

    ${resp}=  Send Verify Login Consumer   ${alternativeNo}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login Consumer   ${alternativeNo}  5
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${alternativeNo}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


























***comment***

JD-TC-Consumer Login-2
    [Documentation]    Update consumer

    ${CUSERPH0}=  Evaluate  ${PUSERNAME}+100100407
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${CUSERPH1}=  Evaluate  ${PUSERNAME0}+405317222
    # ${aulternative}=  Evaluate  ${PUSERNAME0}+405317666
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  Update Consumer   ${firstname2}  ${lastname2}  ${address2}  ${CUSERPH0}    ${CUSERPH_SECOND}   ${dob2}   ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}



