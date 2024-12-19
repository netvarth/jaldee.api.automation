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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Keywords ***

ProviderConsumer Login with google token
    [Arguments]    ${loginId}  ${accountId}  ${token}  ${Google_token}  ${countryCode}=+91  &{kwargs} 
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    # Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${cons_params}   &{locparam}
    ${login}=    Create Dictionary    loginId=${loginId}  accountId=${accountId}  countryCode=${countryCode}
    ${log}=    json.dumps    ${login}
    ${headers2}=     Create Dictionary    Content-Type=application/json    Authorization=${token}   authtoken=${Google_token}
    Set To Dictionary 	${headers2} 	&{tzheaders}
    Check And Create YNW Session
    # Create Session    ynw    ${BASE_URL}  headers=${headers}  verify=true
    ${resp}=    POST On Session    ynw     /consumer/login   headers=${headers2}  data=${log}   expected_status=any   params=${cons_params}
    Check Deprication  ${resp}  ProviderConsumer Login with token
    RETURN  ${resp}



*** Test Cases ***

JD-TC-providerConsumerLogin-4

    [Documentation]    ProviderConsumer Login with google token After Sign up

    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${accountId}=    get_acc_id       ${PUSERNAME70}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${bool[1]}  ${EMPTY}  ${EMPTY}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Customer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200   

    ${google_token}=  Set Variable   googleToken-${token}
   
    ${resp}=    ProviderConsumer Login with google token   ${primaryMobileNo}    ${accountId}  ${token}  ${google_token}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}