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


*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
@{emptylist}
${countryCode}    91

*** Test Cases ***

JD-TC-UpdateProviderConsumer-1
    
    [Documentation]  update Provider Consumer where jaldee integration disabled AND with new customer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME16}

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${resp}=  AddCustomer  ${NewCustomer}
        
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${NewCustomer}

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

JD-TC-UpdateProviderConsumer-2
    
    [Documentation]  update Provider Consumer where jaldee integration Enabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
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

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

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
  
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get ProviderConsumer
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fname}                      FakerLibrary. name

    ${resp}=    Update ProviderConsumer    ${cid}    firstName=${fname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Get ProviderConsumer
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname}

JD-TC-UpdateProviderConsumer-UH1
    
    [Documentation]  update Provider Consumer With invalid Provider Consumer Id

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_cid}=  Generate Random String  3  [NUMBERS]

    ${resp}=    Update ProviderConsumer    ${inv_cid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings     ${resp.json()}    ${NO_PERMISSION}

JD-TC-UpdateProviderConsumer-UH2
    
    [Documentation]  update Provider Consumer Without Provider Consumer Id

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update ProviderConsumer    ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings     ${resp.json()}    ${ENTER_PROCONSUMERID}

JD-TC-UpdateProviderConsumer-3

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
    Set Test Variable  ${email}  ${C_Email}${CUSERNAME_0}.${test_mail}


   ${resp}=    Send Otp For Login    ${CUSERNAME_0}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME_0}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${tokens}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${CUSERNAME_0}     ${accountId}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}


    ${resp}=  Update ProviderConsumer   ${cid}  firstName=${firstname}  lastName=${lastname}    dob=${dob}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  ${OtpPurpose['ConsumerVerifyEmail']}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}   countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}



    ${resp}=   Get ProviderConsumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['dob']}  ${dob} 


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}   countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200



    ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  ${OtpPurpose['ConsumerVerifyEmail']}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get ProviderConsumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['dob']}  ${dob} 


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}   countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"





JD-TC-UpdateProviderConsumer-4
	[Documentation]  Get account contact information of a provider and then do consumer signup with same number and update consumer details and check new change in provider side
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+406380222
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_N}   ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_N}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_N}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_N}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_idN}  ${decrypted_data['id']}

    # Set Test Variable  ${pro_idN}  ${resp.json()['id']}
    Set Test Variable  ${PUSERNAME_N}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_N}${\n}  
    
    Set Test Variable    ${first-name}    ${decrypted_data['firstName']}  
    Set Test Variable    ${last-name}     ${decrypted_data['lastName']} 
    ${pid4}=  get_acc_id  ${PUSERNAME_N}  

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME_N}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    Set Suite Variable  ${country_code}   ${resp.json()['countryCode']} 
    

    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}

   ${resp}=    Send Otp For Login    ${PUSERNAME_N}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PUSERNAME_N}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${tokenss}  ${resp.json()['token']}

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${PUSERNAME_N}     ${accountId}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=    ProviderConsumer Login with token   ${PUSERNAME_N}    ${accountId}  ${tokenss} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${newNo}=  Evaluate  ${PUSERNAME}+77898

    ${resp}=  Update ProviderConsumer   ${cid1}  firstName=${firstname}  lastName=${lastname}    dob=${dob}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Send Verify Login Consumer   ${newNo}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Verify Login Consumer   ${newNo}  ${OtpPurpose['ConsumerVerifyEmail']}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=    Send Otp For Login    ${newNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=    Verify Otp For Login   ${newNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${tokenfornew}  ${resp.json()['token']}


    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${newNo}    ${accountId}  ${tokenfornew}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid2}    ${resp.json()['providerConsumer']}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PUSERNAME_N}    ${accountId}  ${tokenss}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"     "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid5}=  get_acc_id  ${PUSERNAME_N} 

    ${resp}=  Get Account contact information
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid5}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME_N}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

