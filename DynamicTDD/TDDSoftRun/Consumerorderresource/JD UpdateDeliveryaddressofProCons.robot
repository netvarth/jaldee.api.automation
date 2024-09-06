*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        STORE 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***
${minSaleQuantity}  1
${maxSaleQuantity}   60

*** Test Cases ***

JD-TC-Get Delivery Address of ProviderConsumer-1

    [Documentation]  Get Delivery Address of ProviderConsumer

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${accountId}=  get_acc_id  ${HLPUSERNAME35}
    Set Suite Variable    ${accountId} 

    ${Name}=    FakerLibrary.last name
    Set Test Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+201187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END


# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}



      ${new_no}=  Evaluate  ${CUSERNAME21}+257831
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.first_name
      Set Test Variable  ${email}  ${firstname}${CUSERNAME21}.${test_mail}
      ${city}=   get_place
      ${address}=  get_address
      ${landmark}=   FakerLibrary.sentence
      ${postcode}=  FakerLibrary.postcode
      ${whatsapp}=  Create Dictionary  countryCode=+91  number=${new_no}

      ${resp}=   Update Consumer Delivery Address    ${new_no}    ${firstname}    ${lastname}    ${email}    ${address}    ${city}  ${postcode}   ${landmark}  state=${city}  country=${city}  whatsapp=${whatsapp}  location=${locId1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Consumer Delivery Address   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['phoneNumber']}                                              ${new_no}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}                                            ${firstName} 
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}                                                   ${lastname}
    Should Be Equal As Strings    ${resp.json()[0]['email']}                                                       ${email} 
    Should Be Equal As Strings    ${resp.json()[0]['address']}                                                           ${address}
    Should Be Equal As Strings    ${resp.json()[0]['city']}                                                                 ${city}
    Should Be Equal As Strings    ${resp.json()[0]['state']}                                                        ${city}
    Should Be Equal As Strings    ${resp.json()[0]['country']}                                                            ${city}
    Should Be Equal As Strings    ${resp.json()[0]['postalCode']}                                                            ${postcode}
    Should Be Equal As Strings    ${resp.json()[0]['landMark']}                                                             ${landMark}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}                                                           +91
    Should Be Equal As Strings    ${resp.json()[0]['whatsapp']['countryCode']}                                                           +91
    Should Be Equal As Strings    ${resp.json()[0]['whatsapp']['number']}                                                    ${new_no}

JD-TC-Get Delivery Address of ProviderConsumer-UH1

    [Documentation]  Get Delivery Address FROM PROVIDER LOGIN

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME35}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Consumer Delivery Address   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    
JD-TC-Get Delivery Address of ProviderConsumer-UH2

    [Documentation]  Get Delivery Address without login

    ${resp}=    Get Consumer Delivery Address   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
