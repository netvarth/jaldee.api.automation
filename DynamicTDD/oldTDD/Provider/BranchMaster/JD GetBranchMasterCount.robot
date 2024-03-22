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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/ProviderPartnerKeywords.robot

*** Variables ***

@{emptylist}

*** Test Cases ***

JD-TC-CreateBranchMaster-1

    [Documentation]   Get Branch Master Count

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=    Enable Disable Branch    ACTIVE
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    Get BranchMaster Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-2

    [Documentation]   Get Branch Master Count with id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    id-eq=${branchId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-3

    [Documentation]   Get Branch Master Count with Branch code

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    branchCode-eq=${branchCode}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-4

    [Documentation]   Get Branch Master Count with branchName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    branchName-eq=${branchName2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-5

    [Documentation]   Get Branch Master Count with branchAliasName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    branchAliasName-eq=${branchName}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-6

    [Documentation]   Get Branch Master Count with status

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    status-eq=${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-7

    [Documentation]   Get Branch Master Count with location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get BranchMaster Count    location-eq=${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-UH1

    [Documentation]   Get Branch Master Count without Login

    ${resp}=    Get BranchMaster Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-CreateBranchMaster-UH2

    [Documentation]   Get Branch Master Count with consumer Login
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get BranchMaster Count
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}