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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***


JD-TC-GetCategoryByCategoryType-1

    [Documentation]  Create Category as expense and verify.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME92}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

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
    
    ${name}=   FakerLibrary.name
    ${resp}=  Create Category   ${name}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[4]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[4]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[4]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[4]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[4]['status']}        ${toggle[0]}



JD-TC-GetCategoryByCategoryType-2

    [Documentation]  Create Category as Payable and verify.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME92}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    
    ${name}=   FakerLibrary.name
    ${resp}=  Create Category   ${name}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[8]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[8]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[8]['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()[8]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[8]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-3

    [Documentation]  Create Category as Invoice and verify.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME92}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name}=   FakerLibrary.word
    ${resp}=  Create Category   ${name}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[3]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[4]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[4]['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()[4]['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()[4]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[4]['status']}        ${toggle[0]}



JD-TC-GetCategoryByCategoryType-4
    [Documentation]  Create multiple Category as expense and verify.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME92}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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
    ${resp}=  Create Category   ${name1}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id1}   ${resp.json()}

    ${name2}=   FakerLibrary.word
    ${resp}=  Create Category   ${name2}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[5]['id']}            ${category_id1}
    Should Be Equal As Strings  ${resp.json()[5]['name']}          ${name1}
    Should Be Equal As Strings  ${resp.json()[5]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[5]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[5]['status']}        ${toggle[0]}

    Should Be Equal As Strings  ${resp.json()[6]['id']}            ${category_id2}
    Should Be Equal As Strings  ${resp.json()[6]['name']}          ${name2}
    Should Be Equal As Strings  ${resp.json()[6]['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()[6]['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()[6]['status']}        ${toggle[0]}


JD-TC-GetCategoryByCategoryType-UH1

    [Documentation]   Get Category By Id without login

    ${resp}=  Get Category By CategoryType   ${categoryType[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetCategoryByCategoryType-UH2

    [Documentation]   Get Category by Id Using Consumer Login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME92}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Category By CategoryType   ${categoryType[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetCategoryByCategoryType-UH3

    [Documentation]  Get category by category type , without create category.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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

    ${resp}=  Get Category By CategoryType   ${categoryType[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}    
    Should Be Equal As Strings  ${len}  4
   


JD-TC-GetCategoryByCategoryType-UH4

    [Documentation]  Create Category as Expense then update it as PaymentInOut then try to get category type as PaymentInOut.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

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
    ${resp}=  Create Category   ${name1}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id1}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${name2}=   FakerLibrary.word
    ${resp}=  Update Category   ${category_id1}  ${name2}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${resp}=  Get Category By CategoryType   ${categoryType[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}    
    Should Be Equal As Strings  ${len}  9    