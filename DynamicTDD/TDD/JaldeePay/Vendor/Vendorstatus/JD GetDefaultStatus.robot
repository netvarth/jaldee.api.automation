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


JD-TC-Get default vendorstatus-1

    [Documentation]  Get default vendorstatus.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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


    ${resp}=  Get default vendorstatus
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    # Should Be Equal As Strings  ${resp.json()['encId']}        ${encId}
    # Should Be Equal As Strings  ${resp.json()['isDefault']}        ${bool[0]}




JD-TC-Get default vendorstatus-2

    [Documentation]  Create status .update status.then Get default vendorstatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${vender_name}=   FakerLibrary.firstname
    Set Suite Variable  ${vender_name}  

    ${resp}=  Update StatusVendor   ${vender_name}   ${encId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default vendorstatus   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${vender_name}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    # Should Be Equal As Strings  ${resp.json()['encId']}        ${encId}
    # Should Be Equal As Strings  ${resp.json()['isDefault']}        ${bool[0]}

JD-TC-Get default vendorstatus-3

    [Documentation]  Create status .update this status as disable.then Get default vendorstatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200


    ${resp}=  Update Statusofvendor    ${vender_name}   ${encId}  ${toggle[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default vendorstatus 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${vender_name}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[1]}
    # Should Be Equal As Strings  ${resp.json()['encId']}        ${encId}
    # Should Be Equal As Strings  ${resp.json()['isDefault']}        ${bool[0]}

JD-TC-Get default vendorstatus-4

    [Documentation]  set category as default then  Get default vendorstatus

    ${resp}=  Encrypted Provider Login    ${PUSERNAME108}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=  Set status as default    ${encId}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get default vendorstatus
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    # Should Be Equal As Strings  ${resp.json()['accountId']}     ${account_id1}
    # Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}
    # Should Be Equal As Strings  ${resp.json()['encId']}        ${encId}
    # Should Be Equal As Strings  ${resp.json()['isDefault']}        ${bool[0]}



JD-TC-Get default vendorstatus-UH1

    [Documentation]   Get default vendorstatus without login

    ${resp}=  Get default vendorstatus  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get default vendorstatus-UH2

    [Documentation]   Get default vendorstatusy Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default vendorstatus  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}




