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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
@{emptylist}
${countryCode}    91
*** Test Cases ***

JD-TC-ProviderConsumerlogin-1
    
    [Documentation]  update  provider consumer with  new phone number and login with new phone number 
    
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Test Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    

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

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    
    sleep  2s

   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    # ${firstname}=  FakerLibrary.first_name
    # ${lastname}=  FakerLibrary.last_name
    # ${dob}=  FakerLibrary.Date
    # ${gender}=  Random Element    ${Genderlist}
    # Set Test Variable   ${gender}
    # ${ph}=  Evaluate  ${PUSERNAME14}+710108
    # ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()}
    # Log  ${resp.json()}  
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph}${\n}
  

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid18}   ${resp.json()[0]['id']}

    ${phonenumber}    Generate random string    9    [NUMBERS]
    ${phonenumber}    Convert To Integer  ${phonenumber}
    ${dob1}=      FakerLibrary.date
    
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph1}=  Evaluate  ${PUSERNAME14}+71012
    Set Test Variable  ${ph1}
    ${resp}=  UpdateCustomer without email  ${pcid18}   ${firstname1}  ${lastname1}  ${EMPTY}  ${Genderlist[0]}  ${dob1}  ${ph1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}

    # ${firstname1}=  FakerLibrary.first_name
    # ${lastname1}=  FakerLibrary.last_name
    # ${dob1}=  FakerLibrary.Date
    # # ${gender1}=  Random Element    ${Genderlist}
    # ${ph1}=  Evaluate  ${PUSERNAME14}+71075
    # Set Test Variable  ${ph1}
    # ${resp}=  UpdateCustomer without email  ${cid}   ${firstname1}  ${lastname1}  ${EMPTY}  ${gender}  ${dob1}  ${ph1}  ${EMPTY}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${ncid}  ${resp.json()}
    # Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph1}${\n}
    # ${resp}=  GetCustomer  firstName-eq=${firstname1}  phoneNo-eq=${ph1}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph1}  dob=${dob1}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}   favourite=${bool[0]}
 
  


    ${resp}=  Update Customer Details  ${pcid18}   Phonenumber=${phonenumber}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  GetCustomer  phoneNo-eq=${ph1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid18}   ${resp.json()[0]['id']}


    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-ProviderConsumerlogin-2
    
    [Documentation]  update  provider consumer with  new phone number and login with new phone number 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME15}
    ${acc_id15}=  get_acc_id  ${PUSERNAME15}
    Set Test Variable   ${acc_id15}
    ${id15}=  get_id  ${PUSERNAME15}
    Set Test Variable  ${id15}
 
 
    ${provider_id15}=  get_acc_id  ${PUSERNAME15}
    Set Suite Variable  ${provider_id15}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id15}  ${resp.json()['id']}
   
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

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    # sleep 2s
      sleep  2s

  
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
  
    # ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
 
    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

#  *** comment ***
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME16}
    ${acc_id16}=  get_acc_id  ${PUSERNAME16}
    Set Test Variable   ${acc_id16}
    ${id16}=  get_id  ${PUSERNAME16}
    Set Test Variable  ${id16}
 
 
    ${provider_id16}=  get_acc_id  ${PUSERNAME16}
    Set Suite Variable  ${provider_id16}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id16}  ${resp.json()['id']}
   
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

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

   
    sleep  2s

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
    Set Suite Variable  ${token}  ${resp.json()['token']}
 
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

     
    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
        
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME15}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid18}   ${resp.json()[0]['id']}

    ${phonenumber}    Generate random string    9    [NUMBERS]
    ${phonenumber}    Convert To Integer  ${phonenumber}
    ${dob1}=      FakerLibrary.date
    
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    # ${gender1}=  Random Element    ${Genderlist}
    ${ph1}=  Evaluate  ${PUSERNAME14}+71012
    Set Test Variable  ${ph1}
    ${resp}=  UpdateCustomer without email  ${pcid18}   ${firstname1}  ${lastname1}  ${EMPTY}  ${Genderlist[0]}  ${dob1}  ${ph1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ncid}  ${resp.json()}


    # ${resp}=  Update Customer Details  ${pcid18}   Phonenumber=${phonenumber}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  GetCustomer  phoneNo-eq=${ph1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid18}   ${resp.json()[0]['id']}


    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

