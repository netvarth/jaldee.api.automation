*** Settings ***

Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         LOS Lead
Library            Collections
Library            String
Library            json
Library            FakerLibrary
Library            /ebs/TDD/db.py
Library            /ebs/TDD/excelfuncs.py
Resource           /ebs/TDD/ProviderKeywords.robot
Resource           /ebs/TDD/ConsumerKeywords.robot
Resource           /ebs/TDD/ProviderConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-EnableDisableJaldeeLending-1

    [Documentation]  Enable Disable Jaldee Lending

    ${resp}=   Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeLending']}         ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLoanApplication']}    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLead']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLoan']}               ${bool[0]}

    ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeLending']}  ${bool[1]}

    ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['losLead']}  ${bool[1]}

    ${resp}=    Enable Disable Loan Application  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['losLoanApplication']}  ${bool[1]}

    ${resp}=    Enable Disable Los Loan  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['losLoan']}  ${bool[1]}

    ${resp}=    Enable Disable Main RBAC  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Lending AI RBAC   ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    