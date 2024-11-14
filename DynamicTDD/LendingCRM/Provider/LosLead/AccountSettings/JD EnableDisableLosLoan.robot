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

JD-TC-EnableDisableLosLoan-1

    [Documentation]  Enable Disable Los Loan

    ${resp}=   Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeLending']}         ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLoanApplication']}    ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLead']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['losLoan']}               ${bool[0]}

    IF  '${resp.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jaldeeLending']}  ${bool[1]}

    ${resp}=    Enable Disable Los Loan  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['losLoan']}  ${bool[1]}

JD-TC-EnableDisableLosLoan-UH1

    [Documentation]  Enable Disable Los Loan - which is already enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ALREDY_ENABLED}=  format String   ${ALREDY_ENABLED}   Loan

    ${resp}=    Enable Disable Los Loan  ${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREDY_ENABLED}

JD-TC-EnableDisableLosLoan-2

    [Documentation]  Enable Disable Los Loan - disabled which is enabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Los Loan  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-EnableDisableLosLoan-UH2

    [Documentation]  Enable Disable Los Loan - disable already disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ALREDY_DISABLED}=  format String   ${ALREDY_DISABLED}   Loan

    ${resp}=    Enable Disable Los Loan  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ALREDY_DISABLED}

JD-TC-EnableDisableLosLoan-UH3

    [Documentation]  Enable Disable Los Loan - ebanle where Jaldee Lending is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Enable Disable Jaldee Lending  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${ENABLE_JALDEE_LENDING_TO_UPDATE}=  format String   ${ENABLE_JALDEE_LENDING_TO_UPDATE}   Loan

    ${resp}=    Enable Disable Los Loan  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}        ${ENABLE_JALDEE_LENDING_TO_UPDATE}


JD-TC-EnableDisableLosLoan-UH4

    [Documentation]  Enable Disable Los Loan - without Login

    ${resp}=    Enable Disable Los Loan  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}