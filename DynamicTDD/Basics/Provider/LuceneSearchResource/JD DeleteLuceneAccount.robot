***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Search
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${fname}    Mohammed
${lname}    Hisham
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***
JD-TC-Delete Lucene Search Documentation-1
    [Documentation]   Delete Lucene Search Documentation by provider login using id param .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    # Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME20}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${account_id}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    id=${cid20}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s

    ${resp}=    Delete Lucene Search    ${account_id}    id=${cid20}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    id=${cid20}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Delete Lucene Search Documentation-2
    [Documentation]   Delete Lucene Search Documentation by provider login using name param.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME21}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search   ${account_id}   name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s

    ${resp}=    Delete Lucene Search   ${account_id}   name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search   ${account_id}   name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-Delete Lucene Search Documentation-3
    [Documentation]   Delete Lucene Search Documentation by provider login using phoneNumber param.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid20}   ${resp.json()}

    ${CUSERPH3}=  Evaluate  ${CUSERPH}+100200204
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH3}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  AddCustomer  ${CUSERPH3}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=    Create Lucene Search    ${account_id}
    # Log    ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    phoneNumber=18*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  02s

    ${resp}=    Delete Lucene Search    ${account_id}    phoneNumber=18*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    phoneNumber=18*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-Delete Lucene Search Documentation-UH1
    [Documentation]   Delete Lucene Search Documentation by consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep  02s

    ${resp}=    Delete Lucene Search    ${account_id}    phoneNumber=18*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Delete Lucene Search Documentation-UH2
    [Documentation]   Delete Lucene Search Documentation by without login.

    ${resp}=    Delete Lucene Search    ${account_id}    phoneNumber=18*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 