*** Settings ***
Test Teardown    Delete All Sessions
Suite Teardown    Delete All Sessions
Force Tags        UpdateConsumer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

${CUSERPH}      ${CUSERNAME}


*** Test Cases ***
JD-TC-UpConsumerProf-1
    [Documentation]   update Consumer profile of a valid Consumer
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100401
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${address}=  FakerLibrary.address
    Set Suite Variable   ${address}
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}

JD-TC-UpConsumerProf-2
    [Documentation]   update Consumer profile of a valid Consumer with other details
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dob}=  FakerLibrary.Date
    Set Suite Variable   ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable   ${gender}
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}

JD-TC-UpConsumerProf-3
    [Documentation]   update Consumer profile of a valid Consumer with email id
    ${CUSERMAIL0}=   Set Variable  ${C_Email}ph401.${test_mail}
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile With Emailid  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${CUSERMAIL0}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}  email=${CUSERMAIL0}

JD-TC-UpConsumerProf-4
    [Documentation]   update Consumer profile of a valid Consumer with empty email id
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile With Emailid  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}  emailVerified=False

JD-TC-UpConsumerProf-5
    [Documentation]   update Consumer profile of a valid Consumer with another email id
    ${CUSERMAIL1}=   Set Variable  ${C_Email}ph402.${test_mail}
    Set Suite Variable   ${CUSERMAIL1}
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile With Emailid  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${CUSERMAIL1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}  email=${CUSERMAIL1}

JD-TC-UpConsumerProf-6

    [Documentation]   update Consumer profile of a valid Consumer with whats app number and telegram number with country code.

    ${CUSERPH1}=  Evaluate  ${CUSERPH}+1007895
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=   FakerLibrary.last_name
    ${address1}=    FakerLibrary.address

    ${whtpnum}=     Evaluate  ${PUSERNAME}+377457
    ${telgmnum}=    Evaluate  ${PUSERNAME}+658974

    ${whtsp}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${whtpnum}
    ${telegram}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${telgmnum}

    ${resp}=  Update Consumer Profile  ${firstname1}  ${lastname1}  ${address1}  ${dob}  ${gender}   whatsAppNum=${whtsp}  telegramNum=${telegram}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer By Id  ${CUSERPH1}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Consumer Profile  ${resp}  firstName=${firstname1}  lastName=${lastname1}  dob=${dob}  gender=${gender}  address=${address1}  
    Should Be Equal As Strings  ${resp.json()['userProfile']['whatsAppNum']['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['userProfile']['whatsAppNum']['number']}         ${whtpnum}
    Should Be Equal As Strings  ${resp.json()['userProfile']['telegramNum']['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings  ${resp.json()['userProfile']['telegramNum']['number']}         ${telgmnum}

# JD-TC-UpConsumerProf-6
#     [Documentation]   update Consumer profile of a valid provider
#     ${resp}=  ConsumerLogin  ${PUSERNAME13}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer By Id  ${PUSERNAME13}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}

# JD-TC-UpConsumerProf-7
#     [Documentation]   update consumer profile using provider login
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Provider Logout
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  ConsumerLogin  ${PUSERNAME13}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer By Id  ${PUSERNAME13}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}


JD-TC-UpConsumerProf-UH1
    [Documentation]   update consumer profile using provider login
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_EXIST}"


JD-TC-UpConsumerProf-UH2
    [Documentation]   update Consumer profile of a valid Consumer with already existing consumer mail id
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+100100402
    Set Suite Variable   ${CUSERPH1}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH1}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile With Emailid  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${CUSERMAIL1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"

JD-TC-UpConsumerProf-UH3
    [Documentation]   update Consumer profile of a valid Consumer with already existing consumer mail id
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile With Emailid  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  ${CUSERMAIL1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"

JD-TC-UpConsumerProf-UH4
    [Documentation]   update consumer profile without login
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"


JD-TC-UpConsumerProf-UH5

    [Documentation]   update Consumer profile of a valid Consumer with whats app number and telegram number without country code for whats app.

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=   FakerLibrary.last_name
    ${address1}=    FakerLibrary.address

    ${whtpnum}=     Evaluate  ${PUSERNAME}+377457
    ${telgmnum}=    Evaluate  ${PUSERNAME}+658974

    ${whtsp}=  Create Dictionary  countryCode=${EMPTY}   number=${whtpnum}
    ${telegram}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${telgmnum}

    ${resp}=  Update Consumer Profile  ${firstname1}  ${lastname1}  ${address1}  ${dob}  ${gender}   whatsAppNum=${whtsp}  telegramNum=${telegram}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${COUNTRY_CODEREQUIRED_WHATSAPP}

JD-TC-UpConsumerProf-UH6

    [Documentation]   update Consumer profile of a valid Consumer with whats app number and telegram number without country code for telegram number.

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=   FakerLibrary.last_name
    ${address1}=    FakerLibrary.address

    ${whtpnum}=     Evaluate  ${PUSERNAME}+377457
    ${telgmnum}=    Evaluate  ${PUSERNAME}+658974

    ${whtsp}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${whtpnum}
    ${telegram}=  Create Dictionary  countryCode=${EMPTY}   number=${telgmnum}

    ${resp}=  Update Consumer Profile  ${firstname1}  ${lastname1}  ${address1}  ${dob}  ${gender}   whatsAppNum=${whtsp}  telegramNum=${telegram}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${COUNTRY_CODEREQUIRED_TELEGRAM}

   
JD-TC-UpConsumerProf-UH7

    [Documentation]   update Consumer profile of a valid Consumer with whats app number and telegram number with different country code for whats app.

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=   FakerLibrary.last_name
    ${address1}=    FakerLibrary.address

    ${whtpnum}=     Evaluate  ${PUSERNAME}+37574
    ${telgmnum}=    Evaluate  ${PUSERNAME}+65974

    ${whtsp}=  Create Dictionary  countryCode=${countryCodes[2]}   number=${whtpnum}
    ${telegram}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${telgmnum}

    ${resp}=  Update Consumer Profile  ${firstname1}  ${lastname1}  ${address1}  ${dob}  ${gender}   whatsAppNum=${whtsp}  telegramNum=${telegram}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_WHATSAPP}

JD-TC-UpConsumerProf-UH8

    [Documentation]   update Consumer profile of a valid Consumer with whats app number and telegram number with different country code for telegram.

    ${resp}=  ConsumerLogin  ${CUSERPH1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=   FakerLibrary.last_name
    ${address1}=    FakerLibrary.address

    ${whtpnum}=     Evaluate  ${PUSERNAME}+37574
    ${telgmnum}=    Evaluate  ${PUSERNAME}+65974

    ${whtsp}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${whtpnum}
    ${telegram}=  Create Dictionary  countryCode=${countryCodes[3]}   number=${telgmnum}

    ${resp}=  Update Consumer Profile  ${firstname1}  ${lastname1}  ${address1}  ${dob}  ${gender}   whatsAppNum=${whtsp}  telegramNum=${telegram}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_TELEGRAM}


JD-TC-UpConsumerProf-CLEAR
    [Documentation]   update Consumer profile of a valid Consumer
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  ConsumerLogin  ${CUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}

