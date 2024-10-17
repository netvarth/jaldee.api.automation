*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
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

*** Test Cases ***

JD-TC-CreateItemCategory-1
    [Documentation]  Provider Create a Item Category.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-2
    [Documentation]  Provider Create another Item Category contain 250 words.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName}=    FakerLibrary.Text      max_nb_chars=250

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-3
    [Documentation]  Provider Create another Item Category with Number.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-UH1
    [Documentation]  Provider Create another Item Category with same name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${categoryName}=    FakerLibrary.name

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${CATOGORY_NAME_ALRADY_EXIST}

JD-TC-CreateItemCategory-UH2
    [Documentation]  Provider Create a Item Category without Login.

    ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-CreateItemCategory-UH3
    [Documentation]  Provider Create a Item Category with Consumer Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME0}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME0}
    Set Suite Variable    ${accountId} 

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
    ${Name}=    FakerLibrary.last name
    Set Suite Variable    ${Name}
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+208187748
    Set Test Variable  ${email_id}  ${Name}${PhoneNumber}.${test_mail}

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

    ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category   ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 