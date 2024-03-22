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

${autoApprovalUptoAmount}    50000
${autoApprovalUptoAmount2}    70000

*** Test Cases ***

JD-TC-CreateAndUpdateAccountCDLSettings-1
                                  
    [Documentation]               Create CDL Settings

    ${resp}=   Encrypted Provider Login  ${PUSERNAME36}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateAndUpdateAccountCDLSettings-2
                                  
    [Documentation]               Create CDL Settings where auto approval is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[0]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateAndUpdateAccountCDLSettings-3
                                  
    [Documentation]               Create CDL Settings where district Wise Restriction is false

    ${resp}=   Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[0]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateAndUpdateAccountCDLSettings-4
                                  
    [Documentation]               Create CDL Settings where status is disabled

    ${resp}=   Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[1]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-CreateAndUpdateAccountCDLSettings-5
                                  
    [Documentation]               Create CDL Settings and Update it

    ${resp}=   Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[1]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[0]}    ${autoApprovalUptoAmount}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get account level cdl setting
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-CreateAndUpdateAccountCDLSettings-UH1
                                  
    [Documentation]               Create CDL Settings where auto approval amount is empty

    ${resp}=   Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${empty}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings     ${resp.json()}    ${REQ_AMOUNT_REQIRED}

JD-TC-CreateAndUpdateAccountCDLSettings-UH2
                                  
    [Documentation]               Create CDL Settings without provider login

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings     ${resp.json()}    ${SESSION_EXPIRED}

JD-TC-CreateAndUpdateAccountCDLSettings-UH3
                                  
    [Documentation]               Create CDL Settings after consumer login

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=    Create and Update Account level cdl setting    ${bool[1]}    ${autoApprovalUptoAmount2}    ${bool[1]}    ${toggle[0]}    ${bool[1]}    ${empty}   ${bool[1]}    ${bool[1]}  demandPromissoryNoteRequired=${bool[1]}    securityPostDatedChequesRequired=${bool[1]}    loanNature=ConsumerDurableLoan
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings     ${resp.json()}    ${NoAccess}