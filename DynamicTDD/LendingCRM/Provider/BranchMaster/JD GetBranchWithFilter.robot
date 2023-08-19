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

JD-TC-Get Branch With Filter-1

    [Documentation]   Get Branch With Filter

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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

    ${resp}=  Provider Login  ${PUSERNAME46}  ${PASSWORD}
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
    
    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}