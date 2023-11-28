*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Membership Service
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Test Cases ***


JD-TC-Enable_Disable_Member_Service-1

    [Documentation]  Enable Disable Membership Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${resp}=    Enable Disable Membership service     ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Enable_Disable_Member_Service-2

    [Documentation]  Create Membership Service After Enable Membership Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${description}=    FakerLibrary.bs
    ${name}=           FakerLibrary.firstName
    ${displayname}=    FakerLibrary.firstName
    ${effectiveFrom}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo}=      db.add_timezone_date  ${tz}  10  
    Set Suite Variable    ${description}
    Set Suite Variable    ${name}
    Set Suite Variable    ${displayname}
    Set Suite Variable    ${effectiveFrom}
    Set Suite Variable    ${effectiveTo}

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid}    ${resp.json()}

JD-TC-Enable_Disable_Member_Service-3

    [Documentation]  Create Membership Service After Disable Membership Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${resp}=    Enable Disable Membership service     ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name1}=           FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name1}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Enable_Disable_Member_Service-4

    [Documentation]  Disable Membership Service which is already Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${resp}=    Enable Disable Membership service     ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ALREADY_DISABLED}

JD-TC-Enable_Disable_Member_Service-5

    [Documentation]  Enable Membership Service which is already Enabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${resp}=    Enable Disable Membership service     ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable Membership service     ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ALREADY_ENABLED}

JD-TC-Enable_Disable_Member_Service-6

    [Documentation]  Enable Disable Membership Service With Consumer Login

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable Membership service     ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Enable_Disable_Member_Service-7

    [Documentation]  Enable Disable Membership Service Without Login

    ${resp}=    Enable Disable Membership service     ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}