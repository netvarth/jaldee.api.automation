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

JD-TC-UpdateBranchMaster-1

    [Documentation]   Update Branch Master

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
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
    Set Suite Variable  ${branchId}  ${resp.json()['id']}

    ${branchCode2}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode2}
    ${branchName2}=    FakerLibrary.name
    Set Suite Variable    ${branchName2}

    ${resp}=    Update BranchMaster    ${branchId}    ${branchCode2}    ${branchName2}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateBranchMaster-UH1

    [Documentation]   Update Branch Master where branch id is invalid

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account}  ${resp.json()['id']}

    ${invbrid}=    FakerLibrary.Random Number

    ${resp}=    Update BranchMaster    ${invbrid}    ${branchCode2}    ${branchName2}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_BRANCH_ID}


JD-TC-UpdateBranchMaster-UH2

    [Documentation]   Update Branch Master where branch code is empty

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update BranchMaster    ${branchId}    ${empty}    ${branchName2}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_BRANCH_CODE}

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateBranchMaster-UH3

    [Documentation]   Update Branch Master with branch name empty

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${branchCode3}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode3}
    ${branchName3}=    FakerLibrary.name
    Set Suite Variable    ${branchName3}

    ${resp}=    Update BranchMaster    ${branchId}    ${branchCode2}    ${empty}    ${locId}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_BRANCH_NAME}

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateBranchMaster-UH4

    [Documentation]   Update Branch Master where location is empty

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${branchCode3}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode3}
    ${branchName3}=    FakerLibrary.name
    Set Suite Variable    ${branchName3}

    ${resp}=    Update BranchMaster    ${branchId}    ${branchCode3}    ${branchName3}    ${empty}    ${status[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  500

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateBranchMaster-UH5

    [Documentation]   Update Branch Master where status is inactive

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${branchCode3}=    FakerLibrary.Random Number
    Set Suite Variable    ${branchCode3}
    ${branchName3}=    FakerLibrary.name
    Set Suite Variable    ${branchName3}

    ${resp}=    Update BranchMaster    ${branchId}    ${branchCode3}    ${branchName3}    ${locId}    ${status[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get BranchMaster
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateBranchMaster-UH6

    [Documentation]   Update Branch Master without login

    ${resp}=    Update BranchMaster    ${branchId}    ${branchCode3}    ${branchName3}    ${locId}    ${status[1]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}