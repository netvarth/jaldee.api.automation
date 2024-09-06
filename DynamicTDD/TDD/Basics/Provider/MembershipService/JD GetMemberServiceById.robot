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
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***


JD-TC-Get_Member_Service_By_Id-1

    [Documentation]  Get Member Service By Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
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

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Get_Member_Service_By_Id-UH1

    [Documentation]  Get Member Service By Id with invalid member id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invmem}=    Generate random string    4    0123456789

    ${resp}=    Get Membership Service by id    ${invmem}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ID_INVALID}

JD-TC-Get_Member_Service_By_Id-UH2

    [Documentation]  Get Member Service By Id with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}

JD-TC-Get_Member_Service_By_Id-UH3

    [Documentation]  Get Member Service By Id with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get_Member_Service_By_Id-UH4

    [Documentation]  Get Member Service By Id without login

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}