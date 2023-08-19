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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Test Cases ***


JD-TC-Get_Member-1

    [Documentation]  Get Member

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    ${accountId}=    get_acc_id       ${PUSERNAME49}

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
    ${name2}=           FakerLibrary.firstName
    ${displayname2}=    FakerLibrary.firstName
    ${effectiveFrom2}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo2}=    db.add_timezone_date  ${tz}  12
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


    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${membershipid}    ${resp.json()}

    
    ${resp}=    Create Membership Service     ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${membershipid2}    ${resp.json()}

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    Verify Otp For Login   ${number1}   12
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${number1}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    Create Membership     ${firstName}    ${lastName}    ${number1}    ${membershipid}    ${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable     ${memberid1}    ${resp.json()}

    ${resp}=    Create Membership     ${firstName}    ${lastName}    ${number1}    ${membershipid2}    ${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable     ${memberid2}    ${resp.json()}

    ${resp}=    Customer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid2}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}
    Should Be Equal As Strings    ${resp.json()[1]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[1]['firstName']}    ${firstName}
    Should Be Equal As Strings    ${resp.json()[1]['lastName']}    ${lastName}
    Should Be Equal As Strings    ${resp.json()[1]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[1]['countryCode']}    ${countryCodes[1]}

JD-TC-Get_Member-UH1

    [Documentation]  Get Member with provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-Get_Member-UH2

    [Documentation]  Get Member with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get_Member-UH3

    [Documentation]  Get Member without login

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}