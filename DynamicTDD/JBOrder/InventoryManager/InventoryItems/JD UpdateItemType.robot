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

JD-TC-UpdateItemType-1
    [Documentation]  Provider Create a Item Type then try to Update that item name.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
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

    ${TypeName}=    FakerLibrary.name
    Set Suite Variable  ${TypeName}

    ${resp}=  Create Item Type   ${TypeName}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${ty_Id}    ${resp.json()}

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}


    ${resp}=  Update Item Type   ${TypeName1}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${TypeName1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}


JD-TC-UpdateItemType-2
    [Documentation]  Update item TypeName to a Number.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name1}=    FakerLibrary.Random Number

    ${resp}=  Update Item Type   ${Name1}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${Name1}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}

JD-TC-UpdateItemType-3
    [Documentation]  Update item TypeName then update it's Item Type Status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.name

    ${resp}=  Update Item Type   ${Name}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}   

    ${resp}=  Update Item Type Status   ${ty_Id}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]} 

JD-TC-UpdateItemType-4
    [Documentation]  Try to Update Disable item  .

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Name}=    FakerLibrary.name

    ${resp}=  Update Item Type   ${Name}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 
    Should Be Equal As Strings    ${resp.json()['typeCode']}    ${ty_Id}
    Should Be Equal As Strings    ${resp.json()['typeName']}    ${Name}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[1]} 

JD-TC-UpdateItemType-5
    [Documentation]  Update item Type name as same.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Type   ${TypeName1}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemType-6
    [Documentation]  Update item TypeName With EMPTY value.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${Name1}=    FakerLibrary.Random Number

    ${resp}=  Update Item Type   ${EMPTY}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422

    ${resp}=  Get Item Type   ${ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-UpdateItemType-UH1
    [Documentation]  Get Item Type without Login.

    ${resp}=  Update Item Type   ${EMPTY}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemTypeStatus-UH2
    [Documentation]  Get Item Type without Login.

    ${resp}=  Update Item Type Status   ${Ty_Id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemTypeStatus-UH3
    [Documentation]  Get Item Type with Consumer Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME49}
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

    ${resp}=  Update Item Type   ${EMPTY}    ${ty_Id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
