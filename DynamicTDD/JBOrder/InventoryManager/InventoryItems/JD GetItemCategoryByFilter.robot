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
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetItemCategoryByFilter-1

    [Documentation]   Create a Item Category then try to get that item Category with filter(categoryCode).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
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
    Set Suite Variable    ${Ca_Id}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Item Category By Filter   categoryCode-eq=${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}

JD-TC-GetItemCategoryByFilter-2

    [Documentation]   Create a Item Category then try to get that item Category with filter(categoryName).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${categoryName1}=    FakerLibrary.name
    Set Suite Variable  ${categoryName1}

    ${resp}=  Create Item Category   ${categoryName1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ca_Id1}    ${resp.json()}

    ${resp}=  Get Item Category   ${Ca_Id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get Item Category By Filter   categoryName-eq=${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${Ca_Id1}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}

JD-TC-GetItemCategoryByFilter-3

    [Documentation]   Create a Item Category then try to get that item Category with filter(status).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category By Filter   status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${Ca_Id1}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[0]}

JD-TC-GetItemCategoryByFilter-4

    [Documentation]   Update a Item Category Status then try to get that item Category with filter(status).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Category Status   ${Ca_Id1}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category By Filter   status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['categoryCode']}    ${Ca_Id1}
    Should Be Equal As Strings    ${resp.json()[0]['categoryName']}    ${categoryName1}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${toggle[1]}

JD-TC-GetItemCategoryByFilter-UH1

    [Documentation]  GetItemCategoryByFilter without Login.

    ${resp}=  Get Item Category By Filter   categoryName-eq=${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemCategoryByFilter-UH2

    [Documentation]  GetItemCategoryByFilter with Consumer Login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id}=    get_acc_id       ${PUSERNAME174}

    #............provider consumer creation..........

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME20}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    Set Test Variable  ${email}  ${fname}${CUSERNAME20}.${test_mail}

    ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${email}    ${CUSERNAME20}     ${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Item Category By Filter   categoryName-eq=${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
