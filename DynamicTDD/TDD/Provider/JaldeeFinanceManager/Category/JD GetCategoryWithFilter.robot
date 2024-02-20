*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Keywords ***

Get Category With Filter

    [Arguments]   &{param}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/category/list    params=${param}     expected_status=any
    RETURN  ${resp}


*** Test Cases ***


JD-TC-GetCategoryByCategoryType-1

    [Documentation]  Create Category as Vendor and verify with id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name} 
    ${resp}=  Create Category   ${name}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[0]}    id-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-2

    [Documentation]  Create Category as Vendor and verify with name Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[0]}    name-eq=${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-3

    [Documentation]  Create Category as Vendor and verify with account id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-4

    [Documentation]  Create Category as Expense and verify with id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1} 
    ${resp}=  Create Category   ${name1}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=   Get Category With Filter   categoryType-eq=${categoryType[1]}    id-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-5

    [Documentation]  Create Category as Expense and verify with name Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Category With Filter   categoryType-eq=${categoryType[1]}    name-eq=${name1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-6

    [Documentation]  Create Category as Expense and verify with account id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Category With Filter   categoryType-eq=${categoryType[1]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-7

    [Documentation]  Create Category as PaymentsOut and verify with id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${name2}=   FakerLibrary.word
    Set Suite Variable   ${name2} 

    ${resp}=  Create Category   ${name2}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[2]}    id-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-8

    [Documentation]  Create Category as PaymentsOut and verify with name Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[2]}    name-eq=${name2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-9

    [Documentation]  Create Category as PaymentsOut and verify with account id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[2]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-10

    [Documentation]  Create Category as PaymentsIn and verify with id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name3}=   FakerLibrary.word
    Set Suite Variable   ${name3}
    ${resp}=  Create Category   ${name3}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[3]}    id-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name3}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-11

    [Documentation]  Create Category as PaymentsIn and verify with name Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[3]}    name-eq=${name3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name3}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-12

    [Documentation]  Create Category as PaymentsIn and verify with account id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[3]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name3}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

# JD-TC-GetCategoryByCategoryType-5

#     [Documentation]  Create Category as Receivable and verify.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${name}=   FakerLibrary.word
#     ${resp}=  Create Category   ${name}  ${categoryType[4]} 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable   ${category_id1}   ${resp.json()}

#     ${resp}=  Get Category By CategoryType   ${categoryType[4]}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
#     Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name}
#     Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[4]}
#     Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
#     Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-13

    [Documentation]  Create Category as Invoice and verify with id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=   FakerLibrary.word
    Set Suite Variable   ${name4}
    ${resp}=  Create Category   ${name4}  ${categoryType[4]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[4]}    id-eq=${category_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name4}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-14

    [Documentation]  Create Category as Invoice and verify with name Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[4]}    name-eq=${name4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name4}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

JD-TC-GetCategoryByCategoryType-15

    [Documentation]  Create Category as Invoice and verify with account id Filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[4]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name4}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[4]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}
# *** Comments ***

JD-TC-GetCategoryByCategoryType-7

    [Documentation]  Create multiple Category as Vendor and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${name2}=   FakerLibrary.word
    ${resp}=  Create Category   ${name2}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}        ${toggle[0]}

    Should Be Equal As Strings  ${resp.json()[1]['id']}            ${category_id2}
    Should Be Equal As Strings  ${resp.json()[1]['name']}          ${name2}
    Should Be Equal As Strings  ${resp.json()[1]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[1]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-UH1

    [Documentation]   Get Category By Id without login

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[4]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCategoryByCategoryType-UH2

    [Documentation]   Get Category by Id Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[4]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetCategoryByCategoryType-UH3

    [Documentation]  Get category by category type , without create category.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}     []       


JD-TC-GetCategoryByCategoryType-UH4

    [Documentation]  Create Category as Vendor then update it as Expense then try to get category type as vendor.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${name1}=   FakerLibrary.word
    ${resp}=  Create Category   ${name1}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[3]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[3]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[3]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[3]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[3]['status']}        ${toggle[0]}

    ${name2}=   FakerLibrary.word
    ${resp}=  Update Category   ${category_id1}  ${name2}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category With Filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}     []       