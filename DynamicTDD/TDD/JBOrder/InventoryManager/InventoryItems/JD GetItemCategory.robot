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

JD-TC-GetItemCategory-1
    [Documentation]  Provider Create a Item Category then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
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
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemCategory-2
    [Documentation]  Provider Create another Item Category then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName1}=    FakerLibrary.name
    Set Suite Variable  ${categoryName1}

    ${resp}=  Create Item Category   ${categoryName1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${Ca_Id1}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id1}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemCategory-3
    [Documentation]  Provider Create another Item Category with number then try to get that item.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName2}=    FakerLibrary.Random Number
    Set Suite Variable  ${categoryName2}

    ${resp}=  Create Item Category   ${categoryName2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ca_Id2}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id2}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName2}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-GetItemCategory-UH1
    [Documentation]  Get Item Category without Login.

    ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Get Item Category   ${Ca_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemCategory-UH2
    [Documentation]  Get Item Category with Consumer Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME9}
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

    ${resp}=  Get Item Category   ${Ca_Id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 

