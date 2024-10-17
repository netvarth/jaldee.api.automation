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

JD-TC-UpdateItemManufacture-1
    [Documentation]  Provider Create a Item Manufacture then Update Item Manufacture Name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
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

    ${manufactureName}=    FakerLibrary.name
    Set Suite Variable  ${manufactureName}

    ${resp}=  Create Item Manufacture   ${manufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${mf_id}    ${resp.json()}    

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}

    ${manufactureName1}=    FakerLibrary.name

    ${resp}=  Update Item Manufacture   ${manufactureName1}   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName1}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id}

JD-TC-UpdateItemManufacture-2
    [Documentation]  Provider Create another Item Manufacture contain 250 words then update contain 300 words.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ManufactureName}=    FakerLibrary.Text      max_nb_chars=250

    ${resp}=  Create Item Manufacture   ${ManufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${mf_id2}    ${resp.json()}    

    ${resp}=  Get Item Manufacture By Id   ${mf_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id2}

    ${manufactureName1}=    FakerLibrary.Text      max_nb_chars=300

    ${resp}=  Update Item Manufacture   ${manufactureName1}   ${mf_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName1}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id2}

JD-TC-UpdateItemManufacture-3
    [Documentation]  Provider Create another Item Manufacture with Number then update with number and letter.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${letter}=    FakerLibrary.Text
    ${ManufactureName}=    FakerLibrary.Random Number

    ${resp}=  Create Item Manufacture   ${ManufactureName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${mf_id3}    ${resp.json()}    

    ${resp}=  Get Item Manufacture By Id   ${mf_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id3}

    ${resp}=  Update Item Manufacture   ${ManufactureName}${letter}   ${mf_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Manufacture By Id   ${mf_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['manufacturerName']}    ${manufactureName}${letter}
    Should Be Equal As Strings    ${resp.json()['manufacturerCode']}    ${mf_id3}


JD-TC-UpdateItemManufacture-UH1
    [Documentation]  Get Update Manufacture without Login.

    ${resp}=  Update Item Manufacture   ${manufactureName}   ${mf_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemManufacture-UH2
    [Documentation]  Get Update Manufacture with Consumer Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME46}
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
    ${resp}=  Update Item Manufacture   ${manufactureName}   ${mf_id3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
