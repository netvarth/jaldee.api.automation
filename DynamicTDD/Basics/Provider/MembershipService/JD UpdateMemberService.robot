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


JD-TC-Update_Member_Service-1

    [Documentation]  Update Member Service with description

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
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

    ${description2}=    FakerLibrary.bs
    Set Suite Variable    ${description2}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-2

    [Documentation]  Update Member Service name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${name2}=    FakerLibrary.firstName
    Set Suite Variable    ${name2}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-3

    [Documentation]  Update Member Service display name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${displayname2}=    FakerLibrary.firstName
    Set Suite Variable    ${displayname2}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-4

    [Documentation]  Update Member Service effective from

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveFrom2}=    db.add_timezone_date  ${tz}  2
    Set Suite Variable    ${effectiveFrom2}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-5

    [Documentation]  Update Member Service effective To

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveTo2}=    db.add_timezone_date  ${tz}  2
    Set Suite Variable    ${effectiveTo2}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-6

    [Documentation]  Update Member Service Membership Approval Type to Automatic

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[1]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-7

    [Documentation]  Update Member Service allow login is false

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[1]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-8

    [Documentation]  Update Member Service Membership Service Status Enabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[1]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[0]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[1]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-9

    [Documentation]  Update Member Service where Membership Allow login is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${empty}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Update_Member_Service-UH1

    [Documentation]  Update Member Service description is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${empty}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DESC_REQUIRED}  

JD-TC-Update_Member_Service-UH2

    [Documentation]  Update Member Service where name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${empty}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_NAME_REQUIRED}

JD-TC-Update_Member_Service-UH3

    [Documentation]  Update Member Service where display name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${empty}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DISPLAY_NAME_REQUIRED}

JD-TC-Update_Member_Service-UH4

    [Documentation]  Update Member Service effective from is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${empty}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_FROM_REQUIRED}

JD-TC-Update_Member_Service-UH5

    [Documentation]  Update Member Service where effective to is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${empty}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_TO_REQUIRED}

JD-TC-Update_Member_Service-UH6

    [Documentation]  Update Member Service where Membership Approval Type is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${empty}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    500

JD-TC-Update_Member_Service-UH7

    [Documentation]  Update Member Service where Membership Membership Service Status is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    500

JD-TC-Update_Member_Service-UH8

    [Documentation]  Update Member Service where member id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invmemb}=    Generate random string    4    0123456789

    ${resp}=    Update Membership Service     ${invmemb}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${empty}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ID_INVALID}

JD-TC-Update_Member_Service-UH9

    [Documentation]  Update Member Service with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${empty}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Update_Member_Service-UH10

    [Documentation]  Update Member Service with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME65}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${empty}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}

JD-TC-Update_Member_Service-UH11

    [Documentation]  Update Member Service without login

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${empty}    ${MembershipApprovalType[1]}    ${boolean[0]}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Update_Member_Service-UH12

    [Documentation]  Update Member Service where effective from date is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveFrom3}=    db.add_timezone_date  ${tz}  -5
    Set Suite Variable    ${effectiveFrom3}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom3}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom3}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Update_Member_Service-UH13

    [Documentation]  Update Member Service where effectibe To date is past date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${effectiveTo3}=    db.add_timezone_date  ${tz}  -5
    Set Suite Variable    ${effectiveTo3}

    ${resp}=    Update Membership Service     ${memberid}    ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo3}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DATE_TO_SHOULD_NOT_BE_GT_FROM_DATE}