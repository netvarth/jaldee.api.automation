*** Settings ***

Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderPartnerKeywords.robot

*** Variables ***

@{emptylist}

*** Test Cases ***

JD-TC-Get Branch With Filter-1

    [Documentation]   Get Branch With Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${resp}=    Enable Disable Branch    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${branchCode}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode}
    ${branchName}=    FakerLibrary.name
    Set Suite Variable    ${branchName}
    ${branchName2}=    FakerLibrary.name
    Set Suite Variable    ${branchName2}

    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pin}  ${resp.json()['pinCode']}

    ${resp}=  Get LocationsByPincode     ${pin}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${district}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}  
    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchId1}  ${resp.json()['id']}

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName2}    ${locId}    ${status[0]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${branchId2}  ${resp.json()['id']}

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${branchId1}
    Should Be Equal As Strings    ${resp.json()[1]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[1]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[1]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['branchAliasName']}    ${branchName}
    Set Suite Variable    ${branchAliasName2}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[1]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-2

    [Documentation]   Get Branch With Filter with id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    id-eq=${branchId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId1}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName}
    Set Suite Variable    ${branchAliasName2}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-3

    [Documentation]   Get Branch With Filter with Branch code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    branchCode-eq=${branchCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${branchId1}
    Should Be Equal As Strings    ${resp.json()[1]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[1]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[1]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['branchAliasName']}    ${branchName}
    Set Suite Variable    ${branchAliasName2}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[1]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-4

    [Documentation]   Get Branch With Filter with branchName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    branchName-eq=${branchName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-5

    [Documentation]   Get Branch With Filter with branchAliasName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    branchAliasName-eq=${branchName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId1}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName}
    Set Suite Variable    ${branchAliasName2}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-6

    [Documentation]   Get Branch With Filter with status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    status-eq=${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName2}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-7

    [Documentation]   Get Branch With Filter with location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    location-eq=${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName}    ${resp.json()[0]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${branchId1}
    Should Be Equal As Strings    ${resp.json()[1]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[1]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[1]['branchName']}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['branchAliasName']}    ${branchName}
    Set Suite Variable    ${branchAliasName2}    ${branchName}
    Should Be Equal As Strings    ${resp.json()[1]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName2}    ${resp.json()[1]['location']['place']}
    Should Be Equal As Strings    ${resp.json()[1]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-8

    [Documentation]   Get Branch With Filter with locationName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster    locationName-eq=${locationName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${branchId2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}    ${account}
    Should Be Equal As Strings    ${resp.json()[0]['branchCode']}    ${branchCode}
    Should Be Equal As Strings    ${resp.json()[0]['branchName']}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['branchAliasName']}    ${branchName2}
    Set Suite Variable    ${branchAliasName}    ${branchName2}
    Should Be Equal As Strings    ${resp.json()[0]['location']['id']}    ${locId}
    Set Suite Variable    ${locationName}    ${resp.json()[0]['location']['id']}
    Should Be Equal As Strings    ${resp.json()[0]['status']}    ${status[0]}

JD-TC-Get Branch With Filter-UH1

    [Documentation]   Get Branch With Filter without Login

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-Get Branch With Filter-UH2

    [Documentation]   Get Branch With Filter with consumer Login
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME70}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${accountId}=    get_acc_id       ${PUSERNAME70}

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    ${email}=    FakerLibrary.Email

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log    Request Headers: ${resp.request.headers}
    Log    Request Cookies: ${resp.request.headers['Cookie']}
    ${cookie_parts}    ${jsessionynw_value}    Split String    ${resp.request.headers['Cookie']}    =
    Log   ${jsessionynw_value}
  
    ${resp}=    Verify Otp For Login   ${primaryMobileNo}     ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200  
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}    ${countryCodes[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}