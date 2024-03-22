*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
@{emptylist}
${countryCode}    91
*** Test Cases ***

JD-TC-GetProviderConsumer-1
    
    [Documentation]  Get Provider Consumer without enabling jaldee integration
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME14}
    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME14}
    Set Test Variable  ${id}
 
    ${provider_id}=  get_acc_id  ${PUSERNAME14}
    Set Suite Variable  ${provider_id}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    # ${resp}=    Update ProviderConsumer    ${cid}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetProviderConsumer-2
    
    [Documentation]  Get Provider Consumer with jaldee integration enabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME14}
    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME14}
    Set Test Variable  ${id}
 
    ${provider_id}=  get_acc_id  ${PUSERNAME14}
    Set Suite Variable  ${provider_id}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-GetProviderConsumer-UH1
    
    [Documentation]  Get Provider Consumer without Provider Consumer Login

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-GetProviderConsumer-3

    [Documentation]    Checking that provider consurmer is getting replaced or not
    ${resp}=   Encrypted Provider Login  ${PUSERNAME77}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME77}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100201
    Set Suite Variable   ${CUSERPH0}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${CUSERPH0}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERPH0}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${CUSERPH0}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token    ${CUSERPH0}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  FakerLibrary.address
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname1}  ${lastname1}  ${address1}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob1}  ${gender1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Consumer Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token    ${CUSERPH0}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

