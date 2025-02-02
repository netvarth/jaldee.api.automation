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

JD-TC-GetItemTypeCountByFilter-1

    [Documentation]   Create a Item Type Count by Filter

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
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
    Set Suite Variable    ${Ty_Id}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Get Item Type Count By Filter
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        1


JD-TC-GetItemTypeCountByFilter-2

    [Documentation]   Create a Item Type then try to get that item Type with filter(TypeName).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${TypeName1}=    FakerLibrary.name
    Set Suite Variable  ${TypeName1}

    ${resp}=  Create Item Type   ${TypeName1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${Ty_Id1}    ${resp.json()}

    ${resp}=  Get Item Type   ${Ty_Id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Item Type Count By Filter   typeName-eq=${TypeName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        1

JD-TC-GetItemTypeCountByFilter-3

    [Documentation]   Create a Item Type then try to get that item Type with filter(status).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type Count By Filter   status-eq=${toggle[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        2

JD-TC-GetItemTypeCountByFilter-4

    [Documentation]   Update a Item Type Status then try to get that item Type with filter(status).

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME32}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Item Type Status   ${Ty_Id1}    ${toggle[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Type Count By Filter   status-eq=${toggle[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        1

JD-TC-GetItemTypeCountByFilter-UH1

    [Documentation]  Get Item Type Count By Filter without Login.

    ${resp}=  Get Item Type Count By Filter   typeName-eq=${TypeName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 

JD-TC-GetItemTypeCountByFilter-UH2

    [Documentation]  Get Item Type Count By Filter with Consumer Login.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id}=    get_acc_id       ${PUSERNAME174}

    #............provider consumer creation..........

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=    Send Otp For Login    ${CUSERNAME5}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${CUSERNAME5}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    Set Test Variable  ${email}  ${fname}${CUSERNAME5}.${test_mail}

    ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${email}    ${CUSERNAME5}     ${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME5}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Item Type Count By Filter   typeName-eq=${TypeName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess} 
