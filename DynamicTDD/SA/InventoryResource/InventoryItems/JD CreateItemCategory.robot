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
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py

*** Test Cases ***

JD-TC-CreateItemCategory-1

    [Documentation]  SA Create a Item Category.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME260}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${categoryName}=    FakerLibrary.name
    Set Suite Variable  ${categoryName}

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${Ca_id}    ${resp.json()}

JD-TC-CreateItemCategory-2

    [Documentation]  SA Create another Item Category contain 250 words.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${categoryName1}=    FakerLibrary.Text      max_nb_chars=250

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-3

    [Documentation]  SA Create another Item Category with Number.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${categoryName1}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-UH1

    [Documentation]  SA Create another Item Category with same name.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${categoryName}=    FakerLibrary.name

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NAME_ALREADY_EXIST}

JD-TC-CreateItemCategory-UH2

    [Documentation]  SA Create a Item Category without Login.

    ${categoryName}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 

JD-TC-CreateItemCategory-UH3

    [Documentation]  SA Create a Item Category with Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${categoryName1}=    FakerLibrary.Random Number

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SA_SESSION_EXPIRED} 

JD-TC-CreateItemCategory-4

    [Documentation]  SA Create another Item category name is empty.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Item Category SA   ${account_id}  ${empty}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-5

    [Documentation]  SA Create another Item account id as 0.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${categoryName3}=    FakerLibrary.name

    ${resp}=  Create Item Category SA   0  ${categoryName3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-CreateItemCategory-UH4

    [Documentation]  SA Create another Item with same name.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Item Category SA   ${account_id}  ${categoryName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NAME_ALREADY_EXIST}

JD-TC-CreateItemCategory-UH5

    [Documentation]  SA Create another Item account id is invalid.

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc}=     Random Int  min=999  max=9999
    ${categoryName2}=    FakerLibrary.name

    ${resp}=  Create Item Category SA   ${acc}  ${categoryName2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${Invalid_account_id}


JD-TC-CreateItemCategory-6

    [Documentation]  Provider login and checking item category

    ${resp}=  Encrypted Provider Login  ${PUSERNAME260}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Category   ${Ca_Id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['categoryCode']}    ${Ca_Id}
    Should Be Equal As Strings    ${resp.json()['categoryName']}    ${categoryName}
    Should Be Equal As Strings    ${resp.json()['status']}    ${toggle[0]}