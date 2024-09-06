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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***


JD-TC-Enable_Disable_Service-1

    [Documentation]  taking service where service is enabled (Defaultly enabled)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    ${accountId}=    get_acc_id       ${PUSERNAME45}
    Set Suite Variable    ${accountId}

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
    Set Suite Variable    ${membershipid}    ${resp.json()}

    ${resp}=    Get Membership Service by id    ${membershipid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}
    
    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${number1}    Generate random string    10    123456789
    ${number1}    Convert To Integer  ${number1}
    Set Suite Variable    ${number1}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${number1}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${number1}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${number1}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    Create Membership     ${firstName}    ${lastName}    ${number1}    ${membershipid}    ${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable     ${memberid}    ${resp.json()}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Membership By Id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-Enable_Disable_Service-UH1

    [Documentation]  Enable Disable Service Where Service is already Enabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Enable Disable Member Service     ${membershipid}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ALREAD_ENABLED}

JD-TC-Enable_Disable_Service-2

    [Documentation]  Disable an Enabled Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Enable Disable Member Service     ${membershipid}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Enable_Disable_Service-UH2

    [Documentation]  Disable Service Which is Already Disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Enable Disable Member Service     ${membershipid}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ALREAD_DISABLED}

JD-TC-Enable_Disable_Service-UH3

    [Documentation]  Enable Service Without login
    
    ${resp}=    Enable Disable Member Service     ${membershipid}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Enable_Disable_Service-UH4

    [Documentation]  create member for service where service is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description2}=    FakerLibrary.bs
    ${name2}=           FakerLibrary.firstName
    ${displayname2}=    FakerLibrary.firstName
    ${effectiveFrom2}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo2}=      db.add_timezone_date  ${tz}  10 

    ${resp}=    Create Membership Service     ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${membershipid2}    ${resp.json()}

    ${resp}=    Get Membership Service by id    ${membershipid2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Enable Disable Member Service     ${membershipid2}    ${MembershipServiceStatus[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${number2}    Generate random string    10    123456789
    ${number2}    Convert To Integer  ${number2}
    Set Suite Variable    ${number2}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${number2}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${number2}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${number2}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    Create Membership     ${firstName}    ${lastName}    ${number2}    ${membershipid2}    ${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_IS_DISABLED}