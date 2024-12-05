*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
@{emptylist}
${ind_countryCode}    91

*** Test Cases ***

JD-TC-UpdateProviderConsumer-1
    
    [Documentation]  update Provider Consumer where jaldee integration disabled AND with new customer
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME16}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}  ${bool[0]}

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}

    ${resp}=  AddCustomer  ${NewCustomer}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${NewCustomer}

    ${resp}=    Send Otp For Login    ${NewCustomer}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${NewCustomer}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${fname}   FakerLibrary. name
    ${resp}=    Update ProviderConsumer    ${cid}    firstName=${fname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname}

    ${resp}=    Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${NewCustomer}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}


JD-TC-UpdateProviderConsumer-2
    
    [Documentation]  update Provider Consumer where jaldee integration Enabled
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}
   
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END


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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Test Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${ind_countryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fname}   FakerLibrary. name
    ${resp}=    Update ProviderConsumer    ${cid}    firstName=${fname}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=    Get ProviderConsumer
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

JD-TC-UpdateProviderConsumer-UH1
    
    [Documentation]  update Provider Consumer With invalid Provider Consumer Id

    ${account_id}=    get_acc_id       ${PUSERNAME16}

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${ind_countryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${inv_cid}=  Generate Random String  3  [NUMBERS]

    ${resp}=    Update ProviderConsumer    ${inv_cid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings     ${resp.json()}    ${CONSUMER_NOT_FOUND}

JD-TC-UpdateProviderConsumer-UH2
    
    [Documentation]  update Provider Consumer Without Provider Consumer Id

    ${account_id}=    get_acc_id       ${PUSERNAME16}

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${account_id}    ${token}    ${ind_countryCode}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Update ProviderConsumer    ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings     ${resp.json()}    ${ENTER_PROCONSUMERID}

JD-TC-UpdateProviderConsumer-3

    [Documentation]     Update a consumer's phone number with different country code and then update it back to old country code

    ${accountId}=    get_acc_id       ${PUSERNAME16}
    
    ${alt_Number}    Generate random string    5    ${digits} 
    ${alt_Number}    Convert To Integer  ${alt_Number}
    ${PO_Number}=  random_phone_num_generator  subscriber_number_length=10  cc=2
    Log Many  ${PO_Number}
    ${loctype} =    Evaluate    type($PO_Number[1]).__name__
    ${length}=    Evaluate    len(str(int(str(${PO_Number[1]}).lstrip('0'))))
    WHILE    ${length} < 10 
        ${PO_Number}=  random_phone_num_generator  subscriber_number_length=10  cc=2
        Log Many  ${PO_Number}
        ${length}=    Evaluate    len(str(int(str(${PO_Number[1]}).lstrip('0'))))
    END
    ${country_code}=  Set Variable  ${PO_Number[0]}
    ${CUSERNAME_0}=  Set Variable  ${PO_Number[1]}
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

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME_0}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${tokens}  ${resp.json()['token']}

    ${resp}=    Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${CUSERNAME_0}     ${accountId}  Authorization=${tokens}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=  Update ProviderConsumer   ${cid}  firstName=${firstname}  lastName=${lastname}   dob=${dob}  countryCode=${country_code}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME_0}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME_0}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${tokens}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}   countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=   Get ProviderConsumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['countryCode']}  +${country_code}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}   countryCode=${country_code}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Send Verify Login Consumer   ${CUSERNAME_0}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Verify Login Consumer   ${CUSERNAME_0}  ${OtpPurpose['ConsumerVerifyEmail']}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update ProviderConsumer   ${cid}  firstName=${firstname}  lastName=${lastname}   dob=${dob}  countryCode=${ind_countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${CUSERNAME_0}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME_0}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${tokens}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME_0}    ${accountId}  ${tokens}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get ProviderConsumer   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['countryCode']}  +${ind_countryCode}

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
    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PUSERNAME_N}=  Evaluate  ${PUSERNAME}+${PH_Number}
    Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 

    ${firstname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_N}   ${highest_package[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=  Account Activation  ${PUSERNAME_N}  ${OtpPurpose['ProviderSignUp']}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_N}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_N}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_idN}  ${decrypted_data['id']}
    Set Test Variable    ${first-name}    ${decrypted_data['firstName']}  
    Set Test Variable    ${last-name}     ${decrypted_data['lastName']} 

    # Set Test Variable  ${pro_idN}  ${resp.json()['id']}
    Set Test Variable  ${PUSERNAME_N}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_N}${\n}  
    
    ${pid4}=  get_acc_id  ${PUSERNAME_N}  

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}

    ${resp}=  Get Account contact information
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME_N}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${first-name}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${last-name}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}         ${bool[1]} 
    Set Test Variable  ${country_code}   ${resp.json()['countryCode']} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+76068
    Set Test Variable  ${email}  ${firstname}${PUSERNAME_N}${C_Email}.${test_mail}

    ${resp}=    Send Otp For Login    ${PUSERNAME_N}    ${pid4}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PUSERNAME_N}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${tokenss}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${PUSERNAME_N}  ${pid4}  Authorization=${tokenss}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200    

    ${resp}=    ProviderConsumer Login with token   ${PUSERNAME_N}  ${pid4}  ${tokenss} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

    ${PH_Number}=  FakerLibrary.Numerify  %####
    ${newNo}=  Evaluate  ${PUSERNAME}+${PH_Number}

    ${resp}=  Update ProviderConsumer   ${cid1}  firstName=${firstname}  lastName=${lastname}  dob=${dob}  phoneNo=${newNo}  countryCode=${ind_countryCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${newNo}    ${pid4}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${newNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${tokenfornew}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${newNo}    ${pid4}  ${tokenfornew}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid2}    ${resp.json()['providerConsumer']}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PUSERNAME_N}    ${pid4}  ${tokenss}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"     "${NOT_REGISTERED_CUSTOMER}"

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_N}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${pid5}=  get_acc_id  ${PUSERNAME_N} 

    ${resp}=  Get Account contact information
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['account']}              ${pid4}
    Should Be Equal As Strings  ${resp.json()['primaryPhoneNumber']}   ${PUSERNAME_N}
    Should Be Equal As Strings  ${resp.json()['contactFirstName']}     ${firstname}
    Should Be Equal As Strings  ${resp.json()['contactLastName']}      ${lastname}
    Should Be Equal As Strings  ${resp.json()['emailVerified']}        ${bool[0]} 
    Should Be Equal As Strings  ${resp.json()['phoneVerified']}        ${bool[1]} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

