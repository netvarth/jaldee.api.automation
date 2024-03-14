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


*** Test Cases ***


JD-TC-UpdateCategoryStatus-1

    [Documentation]  Create Category .update this category status as disable.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME97}  ${PASSWORD}
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
    
    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${encId}   ${resp.json()}

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-UpdateCategoryStatus-2

    [Documentation]  update this category status as disable..

      ${resp}=  Encrypted Provider Login    ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name}=   FakerLibrary.word

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get by encId  ${encId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[1]}



JD-TC-UpdateCategoryStatus-3

    [Documentation]  update category status without name.

      ${resp}=  Encrypted Provider Login    ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200
    ${name}=   FakerLibrary.word

    ${resp}=  Update VendorCategoryStatus    ${EMPTY}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get by encId  ${encId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[1]}


JD-TC-UpdateCategoryStatus-UH1

    [Documentation]  update category status where id is wrong.

      ${resp}=  Encrypted Provider Login    ${PUSERNAME97}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name}=   FakerLibrary.word

    ${resp}=  Update VendorCategoryStatus    ${name}   ${name}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-UpdateCategoryStatus-UH1

    [Documentation]   Update Category status without login

    ${name}=   FakerLibrary.word
    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateCategoryStatus-UH2

    [Documentation]   Update Category status Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${name}=   FakerLibrary.word
    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-UpdateCategoryStatus-UH3

    [Documentation]  Update category status with the same status again(Enable).

      ${resp}=  Encrypted Provider Login    ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    
    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${encId}   ${resp.json()}

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CATEGORY_ALREADY_ENABLED}=  format String   ${CATEGORY_ALREADY_ENABLED}   ${name}

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CATEGORY_ALREADY_ENABLED}

JD-TC-UpdateCategoryStatus-UH4

    [Documentation]  Update category status with the same status again(Disable).

      ${resp}=  Encrypted Provider Login    ${PUSERNAME88}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${encId}   ${resp.json()}

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${CATEGORY_ALREADY_ENABLED}=  format String   ${CATEGORY_ALREADY_ENABLED}   ${name}

    ${resp}=  Update VendorCategoryStatus    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${CATEGORY_ALREADY_DISABLED}
   