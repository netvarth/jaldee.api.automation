*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        GetConsumer
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



*** Test Cases ***

JD-TC-GetConsumerByAccount-1
    [Documentation]    Get Consumer By Account by provider login search with primary no. and firstname
    ${resp}=   Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comments ***
    ${resp}=  Get Consumer By Id  ${CUSERNAME5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    Set Test Variable  ${dob}       ${resp.json()['userProfile']['dob']}  
    Set Test Variable  ${gender}       ${resp.json()['userProfile']['gender']}  
    Set Test Variable  ${altNo}       ${resp.json()['userProfile']['alternativePhoneNo']}  
    Set Test Variable  ${emailVerified}       ${resp.json()['userProfile']['emailVerified']}
    Set Test Variable  ${fav}       ${resp.json()['favourite']}
    ${resp}=   Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME5}  firstName-eq=${firstname}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify User Profile  ${resp}  firstName=${firstname}  primaryMobileNo=${CUSERNAME5}  alternativePhoneNo=${altNo}  emailVerified=${emailVerified}  gender=${gender}  dob=${dob}
    Verify Response List  ${resp}  0  favourite=${fav}

JD-TC-GetConsumerByAccount-2
    [Documentation]    Get Consumer By Account by provider login search with primary no. and last name
    ${resp}=   Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=   Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}  lastName-eq=${lastname}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify User Profile  ${resp}  lastName=${lastname}  firstName=${firstname}

JD-TC-GetConsumerByAccount-3
    [Documentation]    Get Consumer By Account by provider login search with primary no. firstname and secondname
    ${resp}=   Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=   Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}  firstName-eq=${firstname}  lastName-eq=${lastname}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify User Profile  ${resp}  firstName=${firstname}  lastName=${lastname}

JD-TC-GetConsumerByAccount-4
    [Documentation]    Get Consumer By Account  using primary no. and firstname of a provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${PUSERNAME2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${PUSERNAME2}  firstName-eq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify User Profile  ${resp}  firstName=${firstname}

JD-TC-GetConsumerByAccount-5
    [Documentation]    Get Consumer By Account  using primary no. and lastname of a provider
    ${resp}=   Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${PUSERNAME6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${PUSERNAME6}  lastName-eq=${lastname}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Verify User Profile  ${resp}  firstName=${firstname}  primaryMobileNo=${PUSERNAME6}  lastName=${lastname}

JD-TC-GetConsumerByAccount-UH1
    [Documentation]    Get Consumer By Account by consumer login
    ${resp}=   Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']} 
    ${resp}=   Consumer Logout 
    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}  firstName-eq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${NO_ACCESS_TO_URL}"
    
JD-TC-GetConsumerByAccount-UH2
    [Documentation]    GetConsumerByAccount without login
    ${resp}=   Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=   Consumer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}  firstName-eq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"

JD-TC-GetConsumerByAccount-UH3
    [Documentation]    Get Consumer By Account  using primary no. and firstname of a provider using consumer login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${PUSERNAME0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=   Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${PUSERNAME0}  firstName-eq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"     "${NO_ACCESS_TO_URL}"
    

JD-TC-GetConsumerByAccount-UH4
    [Documentation]    Get Consumer ByAccount  using primary no. and firstname of a provider without login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${PUSERNAME0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=   Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${PUSERNAME0}  firstName-eq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"

JD-TC-GetConsumerByAccount-UH5
    [Documentation]    GetConsumerByAccount with one parameter
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${PHONE_AND_FIRST_NAME_OR_LAST_NAME_REQUIRED}"

JD-TC-GetConsumerByAccount-UH6
    [Documentation]    GetConsumerByAccount using 'neq' filter
    ${resp}=   Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['userProfile']['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['userProfile']['lastName']}  
    ${resp}=  Get Consumer By Account  primaryMobileNo-eq=${CUSERNAME7}  firstName-neq=${firstname}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${CUSTOMER_SEARCH}"



