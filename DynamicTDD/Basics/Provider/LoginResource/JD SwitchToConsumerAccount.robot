*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-SwitchToConsumer-1
    [Documentation]    Provider Login as a valid number and password
    ${resp}=   Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${id}=  get_id  ${PUSERNAME22}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname}     ${resp.json()['firstName']}  
    Set Test Variable  ${lastname}      ${resp.json()['lastName']}  
    Set Test Variable  ${username}      ${resp.json()['userName']}
    Verify Response  ${resp}  id=${id}  userName=${username}  userType=1  accStatus=${status[0]}  firstName=${firstname}  lastName=${lastname}  primaryPhoneNumber=${PUSERNAME22}  isProvider=${bool[1]}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    comment     Provider Login as a consumer
    ${resp}=  ConsumerLogin  ${PUSERNAME22}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_CUSTOMER}"

JD-TC-SwitchToConsumer-UH2
    [Documentation]    Consumer login as provider
    ${resp}=   Encrypted Provider Login  ${CUSERNAME5}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_PROVIDER}"

*** Comment ***
    #     ${resp}=  ConsumerLogin  ${PUSERNAME22}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings  "${resp.json()}"  "${NOT_REGISTERED_USER}"
    # ${id1}=  get_id  ${PUSERNAME22}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${c_firstname}     ${resp.json()['firstName']}  
    # Set Test Variable  ${c_lastname}      ${resp.json()['lastName']}  
    # Set Test Variable  ${c_username}      ${resp.json()['userName']}
    # Verify Response  ${resp}  id=${id1}  userName=${c_username}  userType=0  accStatus=${status[0]}  firstName=${c_firstname}  lastName=${c_lastname}  primaryPhoneNumber=${PUSERNAME22}  isProvider=${bool[1]}
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=   Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}   200
    
    