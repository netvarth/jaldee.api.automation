*** Settings  ***
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


*** Test Cases ***
JD-TC-Create Lucene Search Documentation-1
    [Documentation]   Create Lucene Search Documentation by provider login .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
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

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${account_id}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${account_id}    name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create Lucene Search Documentation-2
    [Documentation]   Create Lucene Search Documentation by Highlevel provider login .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${account_id1}  ${decrypted_data['id']}

    # Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${account_id1}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create Lucene Search Documentation-5
    [Documentation]   Create Lucene Search Documentation two times .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${account_id}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Lucene Search    ${account_id}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


# JD-TC-Create Lucene Search Documentation-UH1
#     [Documentation]   Create Lucene Search Documentation by Consumer  login .

#     ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     # Log  ${resp.content}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Create Lucene Search    ${account_id}
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    401
#     Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

# JD-TC-Create Lucene Search Documentation-UH2
#     [Documentation]   Create Lucene Search Documentation by Without login .

#     ${resp}=    Create Lucene Search    ${account_id}
#     Log    ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 


    