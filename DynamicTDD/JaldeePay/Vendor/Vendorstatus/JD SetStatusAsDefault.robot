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


JD-TC-Set Status as default-1

    [Documentation]  Create Category update this category status as disable.

    ${resp}=  Encrypted Provider Login    ${PUSERNAME104}  ${PASSWORD}
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
    
      ${resp}=  Populate Url For Vendor   ${account_id1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorStatus  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${encId}   ${resp.json()}

    ${resp}=  Get by encIdof vendorstatus   ${encId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    Should Be Equal As Strings  ${resp.json()['isEnabled']}        ${toggle[0]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}        ${bool[0]}


    ${resp}=  Set status as default    ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



  



JD-TC-Set Status as default-UH1

    [Documentation]  Set Status as default- where id is wrong.

      ${resp}=  Encrypted Provider Login    ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name}=   FakerLibrary.word

    ${resp}=   Set status as default    ${name} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Set Status as default-UH2

    [Documentation]   Set Status as default- without login

    ${name}=   FakerLibrary.word
    ${resp}=   Set status as default    ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Set Status as default-UH3

    [Documentation]  Set Status as default- Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Set status as default    ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-Set Status as default-UH4

    [Documentation]  Set Status as default- using another provider login.

      ${resp}=  Encrypted Provider Login    ${PUSERNAME89}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=   Set status as default    ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-Set Status as default-UH5

    [Documentation]  update  status as disable then Set Status as default-..

      ${resp}=  Encrypted Provider Login    ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${name}=   FakerLibrary.word

    ${resp}=  Update Statusofvendor    ${name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set status as default    ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   ${resp.json()}   ${ALREADY_DEFAULT}

