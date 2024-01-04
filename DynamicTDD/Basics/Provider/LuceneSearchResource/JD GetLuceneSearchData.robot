***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Search
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${fname}    mohammed
${lname}    hisham
${abc}    *::*
${firstname}    raigan
${lastname}    gta

${first_name1}    !sham
${last_name1}    v

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
@{emptylist}
${countryCode}    91

# *** Keywords ***
# Get Lucene Searchs
#     [Arguments]      ${all}
#     Check And Create YNW Session
#     ${resp}=    GET On Session    ynw    /provider/customers/es/search    params=${params}     expected_status=any
#     [Return]  ${resp}



*** Test Cases ***
JD-TC-Get Lucene Search Documentation-1
    [Documentation]   Get Lucene Search Documentation by provider login .

    clear_customer    ${PUSERNAME21}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${acc_id}=  get_acc_id  ${PUSERNAME21}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME21}
    Set Test Variable  ${id}
 
    ${provider_id}=  get_acc_id  ${PUSERNAME21}
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME1}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME1}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME1}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME1}    ${accountId}    ${token}    ${countryCode}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    # ${resp}=  AddCustomer  ${CUSERNAME8}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid1}  ${resp.json()}

    # ${resp}=  AddCustomer  ${CUSERNAME20}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid20}   ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${account_id}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    FOR   ${a}  IN RANGE   5000
        ${resp}=    Get Lucene Search    ${account_id}    id=${cid}
        Log    ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings    ${resp.json()[0]['id']}    ${cid}
    END
# *** comment ***
JD-TC-Get Lucene Search Documentation-2
    [Documentation]   Get Lucene Search Documentation by emailid .

    clear_customer    ${PUSERNAME21}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email2}  ${firstname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME4}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search  ${account_id}   emailId=${firstname}*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-3
    [Documentation]   Get Lucene Search Documentation by phoneNumber .

    clear_customer    ${PUSERNAME21}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email2}  ${firstname}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME4}  ${EMPTY}
    Set Suite Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search  ${account_id}   phoneNumber=17*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-4
    [Documentation]   Get Lucene Search Documentation by name.
    clear_customer    ${PUSERNAME21}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME12}    firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-5
    [Documentation]   Get Lucene Search Documentation and get all details.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Lucene Search    ${account_id}    name=m*  id=3  phoneNumber=17*  emailId=${firstname}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-6
    [Documentation]   A Provider Create Lucene Search Documentation then another Provider get lucene search.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME18}    firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    name=m*  
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-Get Lucene Search Documentation-7
    [Documentation]   A Provider Create Lucene Search Documentation then try to  get lucene search by name using Capital /Small latter filttering.

    clear_customer    ${PUSERNAME21}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME15}    firstName=${fname}${SPACE}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=    Get Lucene Search    ${account_id}    name=H*  
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-8
    [Documentation]   A Provider Create Lucene Search Documentation then try to  get lucene search by  using lastname.

    clear_customer    ${PUSERNAME21}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME15}    firstName=${fname}${SPACE}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=    Get Lucene Search    ${account_id}    name=${lname}*  
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get Lucene Search Documentation-UH1
    [Documentation]   Get Lucene Search Documentation by Consumer  login .

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search   ${account_id}   name=m*  
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get Lucene Search Documentation-UH2
    [Documentation]   Get Lucene Search Documentation by Without login .

    ${resp}=    Get Lucene Search    ${account_id}    name=m*  
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

JD-TC-Get Lucene Search Documentation-UH3
    [Documentation]   A Provider Create Lucene Search Documentation then try to  get lucene search by name using Special character.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME16}    firstName=${first_name1}${SPACE}   lastName=${last_name1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=    Get Lucene Search    ${account_id}    name=!*  
    Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    422
    # Should Be Equal As Strings    ${resp.json()}    ${REQUEST_IS_INVALID}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Empty  ${resp.content}