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


JD-TC-Get_Membership_Service_count-1

    [Documentation]  Get Membership Service count

    ${resp}=  Encrypted Provider Login  ${PUSERNAME59}  ${PASSWORD}
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
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${description}=    FakerLibrary.bs
    ${name}=           FakerLibrary.firstName
    ${displayname}=    FakerLibrary.firstName
    ${effectiveFrom}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo}=      db.add_timezone_date  ${tz}  10   

    ${description2}=    FakerLibrary.bs
    ${name2}=           FakerLibrary.firstName
    ${displayname2}=    FakerLibrary.firstName
    ${effectiveFrom2}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo2}=    db.add_timezone_date  ${tz}  12
    ${description3}=    FakerLibrary.bs
    ${name3}=           FakerLibrary.firstName
    ${displayname3}=    FakerLibrary.firstName
    ${effectiveFrom3}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo3}=    db.add_timezone_date  ${tz}  12
    Set Suite Variable    ${description}
    Set Suite Variable    ${name}
    Set Suite Variable    ${displayname}
    Set Suite Variable    ${effectiveFrom}
    Set Suite Variable    ${effectiveTo}
    Set Suite Variable    ${description2}
    Set Suite Variable    ${name2}
    Set Suite Variable    ${displayname2}
    Set Suite Variable    ${effectiveFrom2}
    Set Suite Variable    ${effectiveTo2}
    Set Suite Variable    ${description3}
    Set Suite Variable    ${name3}
    Set Suite Variable    ${displayname3}
    Set Suite Variable    ${effectiveFrom3}
    Set Suite Variable    ${effectiveTo3}

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid}    ${resp.json()}

    ${resp}=    Create Membership Service     ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid2}    ${resp.json()}

    ${resp}=    Create Membership Service     ${description3}    ${name3}    ${displayname3}    ${effectiveFrom3}    ${effectiveTo3}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid3}    ${resp.json()}

    ${resp}=    Get Membership Service Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Get_Membership_Service_count-UH1

    [Documentation]  Get Membership Service count with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    0

JD-TC-Get_Membership_Service_count-UH2

    [Documentation]  Get Membership Service count with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get_Membership_Service_count-UH3

    [Documentation]  Get Membership Service count without login

    ${resp}=    Get Membership Service Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}