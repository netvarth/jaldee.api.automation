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

JD-TC-UpdateItemHsnStatus-1
    [Documentation]  Update Item Hsn Status

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${acc_id}       ${decrypted_data['id']}
    Set Suite Variable  ${userName}     ${decrypted_data['userName']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${hsnCode}=     Random Int  min=1  max=9999
    Set Suite Variable  ${hsnCode}

    ${resp}=    Create Item hns  ${hsnCode} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${hns_id}   ${resp.json()}

    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

    ${resp}=    Update Item hns Status   ${hns_id}   ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200

    ${resp}=    Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}                 200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[1]}


JD-TC-UpdateItemHsnStatus-2
    [Documentation]  Update Item hns Status as already disabled.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item hns Status   ${hns_id}    ${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateItemHsnStatus-3
    [Documentation]  try to Enable ,Disabled Status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item hns Status   ${hns_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

JD-TC-UpdateItemHsnStatus-4
    [Documentation]  try to Enable ,enableled Status.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item hns by id   ${hns_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['hsnCode']}           ${hsnCode}
    Should Be Equal As Strings    ${resp.json()['createdBy']}         ${acc_id} 
    Should Be Equal As Strings    ${resp.json()['createdByName']}     ${userName}
    Should Be Equal As Strings    ${resp.json()['status']}            ${toggle[0]}

    ${resp}=  Update Item hns Status   ${hns_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

JD-TC-UpdateItemHsnStatus-UH1
    [Documentation]  Get Item Unit without Login.

    ${resp}=  Update Item hns Status   ${hns_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-UpdateItemHsnStatus-UH2
    [Documentation]  Get Item Unit with Consumer Login.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME43}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=  get_acc_id  ${HLPUSERNAME43}
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

    ${resp}=  Update Item hns Status   ${hns_id}    ${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
