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


JD-TC-Update_Member-1

    [Documentation]  Update Member

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${user_id}    ${resp.json()['id']}
    ${accountId}=    get_acc_id       ${PUSERNAME67}
    Set Suite Variable    ${accountId}

    ${description}=    FakerLibrary.bs
    ${name}=           FakerLibrary.firstName
    ${displayname}=    FakerLibrary.firstName
    ${effectiveFrom}=  get_date
    ${effectiveTo}=      add_date  10 
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

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

    ${resp}=  ConsumerLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${remarks}=    FakerLibrary.Sentence
    Set Suite Variable    ${remarks}

    ${resp}=    Update Membership    ${firstName}    ${lastName}    ${number1}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-2

    [Documentation]  Update Member with firstname

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstName2}=  FakerLibrary.name
    Set Suite Variable    ${firstName2}

    ${resp}=    Update Membership    ${firstName2}    ${lastName}    ${number1}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastName}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]} 

JD-TC-Update_Member-3

    [Documentation]  Update Member with lastname

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${lastname2}=  FakerLibrary.name
    Set Suite Variable    ${lastname2}

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number1}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number1}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-4

    [Documentation]  Update Member with number

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${number2}    Generate random string    10    123456789
    ${number2}    Convert To Integer  ${number2}
    Set Suite Variable    ${number2}

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-5

    [Documentation]  Update Member with first name is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${empty}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-6

    [Documentation]  Update Member with last name is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${empty}    ${number2}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-7

    [Documentation]  Update Member with number is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${empty}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-8

    [Documentation]  Update Member with country code is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${empty}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-9

    [Documentation]  Update Member with remarks is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${empty}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Member
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Should Be Equal As Strings    ${resp.json()[0]['memberServiceId']}    ${membershipid}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstName2}
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname2}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${number2}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[1]}

JD-TC-Update_Member-10

    [Documentation]  Update Member with memberid is invalid

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fakememberid}=    Generate random string    4    0123456789

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${fakememberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_NOT_EXISTS}

JD-TC-Update_Member-11

    [Documentation]  Update Member with memberid is empty

    ${resp}=  Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    500
    Should Be Equal As Strings    ${resp.json()}    ${JALDEE_OUT_OF_REACH_PROBLEM}

JD-TC-Update_Member-12

    [Documentation]  Update Member without login

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-Update_Member-13

    [Documentation]  Update Member with another provider login

    ${resp}=  Provider Login  ${PUSERNAME68}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Membership    ${firstName2}    ${lastname2}    ${number2}    ${countryCodes[1]}    ${remarks}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}