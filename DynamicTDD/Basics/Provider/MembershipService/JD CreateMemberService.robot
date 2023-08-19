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


JD-TC-Create_Member_Service-1

    [Documentation]  Create Member Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

JD-TC-Create_Member_Service-UH1

    [Documentation]  Create Member Service where description is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${empty}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DESC_REQUIRED}

JD-TC-Create_Member_Service-UH2

    [Documentation]  Create Member Service where name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${empty}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_NAME_REQUIRED}

JD-TC-Create_Member_Service-UH3

    [Documentation]  Create Member Service where display name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${name}    ${empty}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DISPLAY_NAME_REQUIRED}

JD-TC-Create_Member_Service-UH4

    [Documentation]  Create Member Service where effective From is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${empty}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_FROM_REQUIRED}

JD-TC-Create_Member_Service-UH5

    [Documentation]  Create Member Service where effective To is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${empty}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_TO_REQUIRED}

JD-TC-Create_Member_Service-UH6

    [Documentation]  Create Member Service where MembershipApprovalType is automatic

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=    FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name2}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[1]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Member_Service-UH7

    [Documentation]  Create Member Service where allow login is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name3}=    FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name3}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[0]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Member_Service-UH8

    [Documentation]  Create Member Service where MembershipServiceStatus is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name4}=    FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name4}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Member_Service-UH9

    [Documentation]  Create Member Service with consumer Login

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Create_Member_Service-UH10

    [Documentation]  Create Member Service without Login

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Create_Member_Service-UH11

    [Documentation]  Create Member Service where effective from is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveFrompast}=    add_date  -10

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrompast}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_FROM_SHOULD_BE_GT_TODAY}

JD-TC-Create_Member_Service-UH12

    [Documentation]  Create Member Service where effective to is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveTopast}=    add_date  -10

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTopast}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_TO_SHOULD_NOT_BE_GT_FROM_DATE}

JD-TC-Create_Member_Service-UH13

    [Documentation]  Create Member Service where Membership Approval Type is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${empty}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    500
    Should Be Equal As Strings    ${resp.json()}    ${JALDEE_OUT_OF_REACH_PROBLEM}


JD-TC-Create_Member_Service-UH14

    [Documentation]  Create Member Service where Membership Allow login is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name5}=    FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name5}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${empty}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Create_Member_Service-UH15

    [Documentation]  Create Member Service where Membership Membership Service Status is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name6}=    FakerLibrary.firstName

    ${resp}=    Create Membership Service     ${description}    ${name6}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    500
    Should Be Equal As Strings    ${resp.json()}    ${JALDEE_OUT_OF_REACH_PROBLEM}