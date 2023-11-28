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


JD-TC-Member_Creation_From_Provider_Dashboard-1

    [Documentation]  Member Creation From Provider Dashboard

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}

    ${accountId}=    get_acc_id       ${PUSERNAME56}
    Set Suite Variable    ${accountId}

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
    Set Suite Variable    ${memberserviceid}    ${resp.json()}

    ${resp}=    Get Membership Service by id    ${memberserviceid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberserviceid}
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
    ${phone}    Generate random string    10    123456789
    ${phone}    Convert To Integer  ${phone}
    Set Suite Variable    ${phone}

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${firstName}  ${lastName}  ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Member_Creation_From_Provider_Dashboard-UH1

    [Documentation]  Member Creation From Provider Dashboard - same mobile number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${firstName}  ${lastName}  ${phone}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${PRO_CON_ALREADY_EXIST}

JD-TC-Member_Creation_From_Provider_Dashboard-UH2

    [Documentation]  Member Creation From Provider Dashboard - invalid mobile number

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=  FakerLibrary.Random Number   

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${firstName}  ${lastName}  ${inv}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_PHONE}

JD-TC-Member_Creation_From_Provider_Dashboard-UH3

    [Documentation]  Member Creation From Provider Dashboard - invalid Member service Id 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=  FakerLibrary.Random Number   
    ${phone2}    Generate random string    10    3456789
    ${phone2}    Convert To Integer  ${phone2}
    Set Suite Variable    ${phone2}

    ${resp}=    Member Creation From Provider Dashboard  ${inv}  ${firstName}  ${lastName}  ${phone2}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_DOES_NOT_EXIST}

JD-TC-Member_Creation_From_Provider_Dashboard-UH4

    [Documentation]  Member Creation From Provider Dashboard - EMPTY Member service Id 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone3}    Generate random string    10    3456789
    ${phone3}    Convert To Integer  ${phone3}
    Set Suite Variable    ${phone3}

    ${resp}=    Member Creation From Provider Dashboard  ${empty}  ${firstName}  ${lastName}  ${phone3}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_REQUIRED}

JD-TC-Member_Creation_From_Provider_Dashboard-UH5

    [Documentation]  Member Creation From Provider Dashboard - firstname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone4}    Generate random string    10    3456789
    ${phone4}    Convert To Integer  ${phone4}
    Set Suite Variable    ${phone4}

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${empty}  ${lastName}  ${phone4}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Member_Creation_From_Provider_Dashboard-UH6

    [Documentation]  Member Creation From Provider Dashboard - lastname is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone5}    Generate random string    10    3456789
    ${phone5}    Convert To Integer  ${phone5}
    Set Suite Variable    ${phone5}

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${firstName}  ${empty}  ${phone5}  ${countryCodes[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Member_Creation_From_Provider_Dashboard-UH7

    [Documentation]  Member Creation From Provider Dashboard - country code is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${phone4}    Generate random string    10    3456789
    ${phone4}    Convert To Integer  ${phone4}
    Set Suite Variable    ${phone4}

    ${resp}=    Member Creation From Provider Dashboard  ${memberserviceid}  ${firstName}  ${lastName}  ${phone4}  ${empty}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${COUNTRY_CODEREQUIRED}

