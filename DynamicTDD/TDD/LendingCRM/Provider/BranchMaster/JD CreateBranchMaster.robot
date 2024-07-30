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

    [Documentation]   Create Branch Master

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
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

    ${resp}=    Enable Disable Branch    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${branchCode}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode}
    ${branchName}=    FakerLibrary.name
    Set Suite Variable    ${branchName}

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
    Set Suite Variable  ${branchid1}  ${resp.json()['id']} 



JD-TC-CreateBranchMaster-UH1

    [Documentation]   Create Branch Master where branch code is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    # ${branchCode}=    FakerLibrary.Random Number
    ${branchName}=    FakerLibrary.name

    ${resp}=    Create BranchMaster    ${empty}    ${branchName}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_BRANCH_CODE}

JD-TC-CreateBranchMaster-UH2

    [Documentation]   Create Branch Master where branch name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create BranchMaster    ${branchCode}    ${empty}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_BRANCH_NAME}

JD-TC-CreateBranchMaster-UH3

    [Documentation]   Create Branch Master where location is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${empty}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${LOCATION_NOT_FOUND}

JD-TC-CreateBranchMaster-UH4

    [Documentation]   Create Branch Master where status is inactive

    ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBranchMaster-UH5

#     [Documentation]   Create Branch Master where district is empty

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${empty}    ${state}    ${pin}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBranchMaster-UH6

#     [Documentation]   Create Branch Master where state is empty

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${empty}    ${pin}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBranchMaster-UH7

#     [Documentation]   Create Branch Master where pin is empty

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${empty}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-CreateBranchMaster-UH8

#     [Documentation]   Create Branch Master where pin is invalid
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME69}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${invpin}=    Random Number 	digits=5

#     ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}    ${district}    ${state}    ${invpin}
#     Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateBranchMaster-UH9

    [Documentation]   Create Branch Master without provider login

    ${resp}=    Create BranchMaster    ${branchCode}    ${branchName}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}