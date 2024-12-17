*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Get Provider By Id-1

    [Documentation]  Get Provider By Id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable   ${firstname}   ${decrypted_data['firstName']}
    Set Suite Variable   ${lastname}   ${decrypted_data['lastName']}
    Set Suite Variable   ${primaryPhoneNumber}   ${decrypted_data['primaryPhoneNumber']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${resp}=  Get Provider By Id  ${PUSERNAME111}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}   ${lastname} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${primaryPhoneNumber}

JD-TC-Get Provider By Id-UH1

    [Documentation]  Get Provider By Id Details without login
    ${resp}=  Get Provider By Id  ${PUSERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Get Provider By Id-UH2

    [Documentation]  Get Provider By Id  using consumer login
    # ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME8}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME8}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME8}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Provider By Id  ${PUSERNAME111}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Get Provider By Id-UH3

    [Documentation]  Get Provider details using id of another provider 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Provider By Id  ${PUSERNAME111}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
