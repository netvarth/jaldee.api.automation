*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        GetConsumer
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

${CUSERPH}      ${CUSERNAME}


*** Test Cases ***

JD-TC-Get Consumer By Id-1
    [Documentation]  get a consumer's own details using consumer id
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100301
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
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
    ${resp}=   Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  gender=${gender}  address=${address}  primaryMobileNo=${CUSERPH0}


JD-TC-Get Consumer By Id-4
    [Documentation]  get a consumer's details using consumer id by a provider login
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}    ${resp.json()['firstName']}
    Set Test Variable  ${lastname}    ${resp.json()['lastName']}
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}


JD-TC-Get Consumer By Id-UH1
    [Documentation]  get a consumer's details using consumer id by another consumer
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Get Consumer By Id-UH2
    [Documentation]    Get Consumer By Id without login
    ${resp}=  Get Consumer By Id  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"



JD-TC-Get Consumer By Id-UH3
    [Documentation]  get a providers  details using consumer Id by consumer login 
    ${resp}=   Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}    ${resp.json()['firstName']}
    Set Test Variable  ${lastname}    ${resp.json()['lastName']}
    ${resp}=  Get Consumer By Id  ${PUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



JD-TC-Get Consumer By Id-UH4
    [Documentation]  get a provider's own details using consumer id by provider login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${firstname}    ${resp.json()['firstName']}
    Set Suite Variable  ${lastname}    ${resp.json()['lastName']}
    # Set Test Variable  ${firstname}    ${resp.json()['firstName']}
    # Set Test Variable  ${lastname}    ${resp.json()['lastName']}
    ${resp}=  Get Consumer By Id  ${PUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404 
    Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_EXIST}"


















# JD-TC-Get Consumer By Id-2
#     [Documentation]  get a provider's own details using consumer id by provider login
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${firstname}    ${resp.json()['firstName']}
#     Set Test Variable  ${lastname}    ${resp.json()['lastName']}
#     ${resp}=  Get Consumer By Id  ${PUSERNAME11}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${PUSERNAME11}


# JD-TC-Get Consumer By Id-3
#     [Documentation]  get a provider's own details using consumer Id by consumer login of a provider
#     ${resp}=   Consumer Login  ${PUSERNAME12}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${firstname}    ${resp.json()['firstName']}
#     Set Test Variable  ${lastname}    ${resp.json()['lastName']}
#     ${resp}=  Get Consumer By Id  ${PUSERNAME12}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}  primaryMobileNo=${PUSERNAME12}



# JD-TC-Get Consumer By Id-5
#     [Documentation]  get a provider's details using consumer id by a provider login
#     ${resp}=   Consumer Login  ${PUSERNAME1}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${firstname}    ${resp.json()['firstName']}
#     Set Test Variable  ${lastname}    ${resp.json()['lastName']}
#     ${resp}=  Consumer Logout
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer By Id  ${PUSERNAME1}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Consumer Profile  ${resp}  firstName=${firstname}  lastName=${lastname}


# JD-TC-Get Consumer By Id-UH3
#     [Documentation]  get a consumer's details using consumer id by a consumer login of a provider
#     ${resp}=   Consumer Login  ${PUSERNAME6}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Get Consumer By Id  ${CUSERNAME4}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



